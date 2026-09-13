import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';

import '../features/focus/focus_bar_host.dart';
import '../features/focus/focus_controller.dart';
import '../features/home/home_screen.dart';
import '../features/state/ambient_measurement.dart';


class TabbedShell extends ConsumerWidget {
  const TabbedShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusActive = ref.watch(
      focusControllerProvider.select((value) => value.isActive),
    );
    final homeForeground =
        GoRouterState.of(context).uri.path == HomeScreen.path;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      final ambient = ref.read(ambientMeasurementProvider);
      unawaited(
        homeForeground && !focusActive ? ambient.start() : ambient.stop(),
      );
    });
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [


          const FocusBarHost(),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: context.sb.line)),
            ),
            child: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (index) => navigationShell.goBranch(
                index,


                initialLocation: index == navigationShell.currentIndex,
              ),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.grid_view_outlined),
                  selectedIcon: Icon(Icons.grid_view_rounded),
                  label: 'Subjects',
                ),
                NavigationDestination(
                  icon: Icon(Icons.insights_outlined),
                  selectedIcon: Icon(Icons.insights_rounded),
                  label: 'Activity',
                ),
                NavigationDestination(
                  icon: Icon(Icons.tune_outlined),
                  selectedIcon: Icon(Icons.tune_rounded),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
