import 'package:docu_fill/presenter/page.dart';
import 'package:docu_fill/route/src/routes_path.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'shell',
);

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: RoutesPath.home, // Use the constant for initialLocation
  redirect: (context, state) {
    if (state.path == "/") return RoutesPath.home;
    return state.path;
  },
  routes: <RouteBase>[
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return MainPage(child: child);
      },
      routes: <RouteBase>[
        GoRoute(
          path: RoutesPath.home, // Use constant (relative)
          builder: (BuildContext context, GoRouterState state) {
            return const HomePage();
          },
          routes: <RouteBase>[
            GoRoute(
              path: RoutesPath.configure, // Use constant (relative)
              builder: (BuildContext context, GoRouterState state) {
                final path = ConfigurePage.queryPath(
                  stateQuery: state.uri.queryParameters,
                );
                return ConfigurePage(path: path);
              },
            ),
            GoRoute(
              path: RoutesPath.upload, // Use constant (relative)
              builder: (BuildContext context, GoRouterState state) {
                return const UploadPage();
              },
            ),
          ],
        ),
        GoRoute(
          path: RoutesPath.setting, // Use constant (relative)
          builder: (BuildContext context, GoRouterState state) {
            return const SettingPage();
          },
          routes: <RouteBase>[
            /* GoRoute(
                  path: AppRoutes.upload, // Use constant (relative)
                  builder: (BuildContext context, GoRouterState state) {
                    return const UploadPage();
                  },
                ),*/
            GoRoute(
              path: RoutesPath.theme, // Use constant (relative)
              builder: (BuildContext context, GoRouterState state) {
                return const SettingPage();
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
