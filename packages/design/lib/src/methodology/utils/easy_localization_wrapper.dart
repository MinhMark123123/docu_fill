import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class EasyLocalizationWrapper extends StatelessWidget {
  final Widget child;

  const EasyLocalizationWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return EasyLocalization(
      supportedLocales: [Locale('en', 'US'), Locale('vi', 'VN')],
      path: 'assets/translations',
      fallbackLocale: Locale('vi', 'VN'),
      startLocale: Locale('vi', 'VN'),
      child: child,
    );
  }
}
