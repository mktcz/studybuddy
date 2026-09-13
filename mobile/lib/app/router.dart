import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/activity/activity_screen.dart';
import '../features/home/home_screen.dart';
import '../features/reader/reader_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/subject/subject_screen.dart';
import 'shell.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();


final router = GoRouter(
  navigatorKey: _rootKey,
  initialLocation: HomeScreen.path,
  routes: [
    ShellRoute(
      navigatorKey: _shellKey,
      builder: (context, state, child) => child,
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              TabbedShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: HomeScreen.path,
                  builder: (context, state) => const HomeScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: ActivityScreen.path,
                  builder: (context, state) => const ActivityScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: SettingsScreen.path,
                  builder: (context, state) => const SettingsScreen(),
                ),
              ],
            ),
          ],
        ),


        GoRoute(
          path: '/subject/:id',
          builder: (context, state) =>
              SubjectScreen(subjectId: state.pathParameters['id']!),
          routes: [
            GoRoute(
              path: 'read/:sourceId',
              builder: (context, state) => ReaderScreen(
                subjectId: state.pathParameters['id']!,
                sourceId: state.pathParameters['sourceId']!,
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);
