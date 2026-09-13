import 'dart:async';

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:ui/ui.dart';

import '../features/biosignal/debug_capture.dart';
import '../features/biosignal/watch_control.dart';
import '../features/focus/focus_controller.dart';
import '../features/focus/start_flow.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../domain/study_logic.dart';
import '../features/state/hsi_providers.dart';
import '../features/state/rest_alert_host.dart';
import '../features/widget/home_widget_service.dart';
import 'providers.dart';
import 'router.dart';

class StudyBuddyApp extends ConsumerStatefulWidget {
  const StudyBuddyApp({super.key});

  @override
  ConsumerState<StudyBuddyApp> createState() => _StudyBuddyAppState();
}

class _StudyBuddyAppState extends ConsumerState<StudyBuddyApp>
    with WidgetsBindingObserver {
  final _watchControl = WatchControlChannel();
  final _homeWidget = const HomeWidgetService();
  StreamSubscription<Uri?>? _widgetClicks;
  StreamSubscription<List<ConnectivityResult>>? _connectivity;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _watchControl.listen(
      onControl: _applyControl,
      onDebugCapture: (args) {
        unawaited(ref.read(debugCaptureControllerProvider).handle(args));
      },
    );


    _watchControl.takePendingDebugCapture().then((args) {
      if (args != null) {
        unawaited(ref.read(debugCaptureControllerProvider).handle(args));
      }
    });

    _watchControl.takePending().then((control) {
      if (control != null) _applyControl(control);
    });

    _widgetClicks = HomeWidget.widgetClicked.listen(_openWidgetLink);
    HomeWidget.initiallyLaunchedFromHomeWidget().then(_openWidgetLink);
    _connectivity = Connectivity().onConnectivityChanged.listen((results) {
      if (!results.contains(ConnectivityResult.none)) _retryCloudQueue();
    });
  }


  Future<void> _openWidgetLink(Uri? uri) async {
    if (uri == null || uri.host != 'start') return;

    final subjectId = uri.queryParameters['subject'];
    if (subjectId == null) return;

    final subject = await ref.read(databaseProvider).findSubject(subjectId);
    if (subject == null || !mounted) return;

    final context = router.routerDelegate.navigatorKey.currentContext;
    if (context == null || !context.mounted) return;


    if (ref.read(focusControllerProvider).isActive) {
      router.go('/subject/$subjectId');
      return;
    }
    await startSessionFlow(context, ref, subject);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    _watchControl.takePending().then((control) {
      if (control != null) _applyControl(control);
    });


    _syncHomeWidget();
    _retryCloudQueue();
  }

  void _retryCloudQueue() {
    unawaited(
      ref.read(hsiEngineProvider).flushIngestion().then((_) {
        ref.invalidate(ingestionStatusProvider);
        ref.invalidate(integrationHealthProvider);
      }),
    );
  }


  void _applyControl(WatchControl control) {
    final focus = ref.read(focusControllerProvider);
    if (!focus.isActive) return;
    if (control.sessionId != null && control.sessionId != focus.sessionId) {
      return;
    }

    final controller = ref.read(focusControllerProvider.notifier);
    switch (control.action) {
      case WatchControlAction.stop:
        controller.stop();
      case WatchControlAction.pause:
        if (focus.running) controller.togglePause();
      case WatchControlAction.resume:
        if (!focus.running) controller.togglePause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _widgetClicks?.cancel();
    _connectivity?.cancel();
    _watchControl.dispose();
    super.dispose();
  }


  void _syncHomeWidget() {
    final subjects = ref.read(subjectSummariesProvider).value;
    final byDay = ref.read(minutesByDayProvider).value;
    if (subjects == null || byDay == null) return;


    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    unawaited(
      _homeWidget.refresh(
        minutesByDay: byDay,
        subjects: subjects,
        todayMinutes: byDay[today] ?? 0,
        streak: streakDays(byDay, today: today),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(subjectSummariesProvider, (_, _) => _syncHomeWidget());
    ref.listen(minutesByDayProvider, (_, _) => _syncHomeWidget());


    ref.watch(hsiStatusProvider);

    final profile = ref.watch(profileProvider);
    final theme = studyTheme();
    final darkTheme = studyTheme(brightness: Brightness.dark);
    if (profile.isLoading) {
      return MaterialApp(
        title: 'Study Buddy',
        debugShowCheckedModeBanner: false,
        theme: theme,
        darkTheme: darkTheme,
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    if (profile.hasError) {
      return MaterialApp(
        title: 'Study Buddy',
        debugShowCheckedModeBanner: false,
        theme: theme,
        darkTheme: darkTheme,
        home: Scaffold(
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Study Buddy could not open its local data. Close the app and try again.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ),
          ),
        ),
      );
    }
    if (profile.value?.setupComplete != true) {
      return MaterialApp(
        title: 'Study Buddy',
        debugShowCheckedModeBanner: false,
        theme: theme,
        darkTheme: darkTheme,
        home: const OnboardingScreen(),
      );
    }

    return MaterialApp.router(
      title: 'Study Buddy',
      debugShowCheckedModeBanner: false,
      theme: theme,
      darkTheme: darkTheme,
      routerConfig: router,
      builder: (context, child) =>
          RestAlertHost(child: child ?? const SizedBox.shrink()),
    );
  }
}
