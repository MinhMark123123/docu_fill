import 'package:design/ui.dart';
import 'package:docu_fill/route/routers.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

import 'core/src/loading_dialog_manager.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return EasyLocalizationWrapper(
      child: ScreenUtilWrapper(
        builder: (context, _) {
          return MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            title: AppLang.appName.tr(),
            darkTheme: AppTheme.darkTheme,
            theme: AppTheme.lightTheme,
            themeMode: ThemeMode.light,
            builder: (context, child) {
              return LoadingWrapper(child: child!);
            },
          );
        },
      ),
    );
  }
}
