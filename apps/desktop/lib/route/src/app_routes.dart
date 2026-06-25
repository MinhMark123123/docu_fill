import 'package:data/data.dart';
import 'package:docu_fill/features/page.dart';
import 'package:docu_fill/features/src/home/input_page.dart';
import 'package:docu_fill/features/src/home/quick_image_input_page.dart';
import 'package:docu_fill/features/src/main/main_page.dart';
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
  initialLocation: RoutesPath.splash, // Set splash as the initial location
  routes: <RouteBase>[
    GoRoute(
      path: RoutesPath.splash,
      builder: (BuildContext context, GoRouterState state) {
        return const SplashPage();
      },
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return MainPage(child: child, state: state);
      },
      routes: <RouteBase>[
        GoRoute(
          path: RoutesPath.home, // Use constant (relative)
          builder: (BuildContext context, GoRouterState state) {
            final ids = InputPage.parseIds(state);
            return HomePage(detailChild: InputPage(key: Key("$ids"), ids: ids));
          },
          routes: <RouteBase>[
            GoRoute(
              path: RoutesPath.quickImageInput,
              builder: (BuildContext context, GoRouterState state) {
                final extra = state.extra as Map<String, dynamic>;
                final imageFields = extra['imageFields'] as List<TemplateField>;
                final currentValues =
                    extra['currentValues'] as Map<String, String?>;
                return QuickImageInputPage(
                  imageFields: imageFields,
                  currentValues: currentValues,
                );
              },
            ),
            GoRoute(
              path: RoutesPath.configure, // Use constant (relative)
              builder: (BuildContext context, GoRouterState state) {
                final path = ConfigurePage.queryPath(
                  stateQuery: state.uri.queryParameters,
                );
                final mode = ConfigurePage.queryIsEditMode(
                  stateQuery: state.uri.queryParameters,
                );
                final idEdit = ConfigurePage.queryIdEdit(
                  stateQuery: state.uri.queryParameters,
                );
                return ConfigurePage(path: path, mode: mode, idEdit: idEdit);
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
          path: RoutesPath.tool, // Use constant (relative)
          builder: (BuildContext context, GoRouterState state) {
            return const ToolPage();
          },
        ),
        GoRoute(
          path: RoutesPath.setting, // Use constant (relative)
          builder: (BuildContext context, GoRouterState state) {
            return const SettingPage();
          },
          routes: <RouteBase>[
            GoRoute(
              path: RoutesPath.theme, // Use constant (relative)
              builder: (BuildContext context, GoRouterState state) {
                return const SettingPage();
              },
            ),
            GoRoute(
              path: RoutesPath.logHistory,
              builder: (BuildContext context, GoRouterState state) {
                return LogHistoryPage();
              },
              routes: [
                GoRoute(
                  path: RoutesPath.logDetail,
                  builder: (BuildContext context, GoRouterState state) {
                    final fileName =
                        state.uri.queryParameters['fileName'] ?? "";
                    return LogDetailPage(fileName: fileName);
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
