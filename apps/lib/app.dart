import 'package:docu_fill/const/const.dart';
import 'package:docu_fill/route/routers.dart';
import 'package:docu_fill/ui/ui.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

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
          );
        },
      ),
    );
  }
}
