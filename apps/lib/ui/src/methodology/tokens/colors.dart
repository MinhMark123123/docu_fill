import 'dart:ui';

class AppColorValue {
  final Color dark;
  final Color light;

  AppColorValue({required this.dark, required this.light});
}

class AppColorsDefine {
  AppColorsDefine._();
  static final containerBackground = AppColorValue(
    dark: Color(0xFFFFFFFF),
    light: Color(0xFFFFFFFF),
  );
  static final buttonBackground = AppColorValue(
    dark: Color(0xFFF0F2F5),
    light: Color(0xFFF0F2F5),
  );
  static final bodyTextColor = AppColorValue(
    dark: Color(0xFF61758A),
    light: Color(0xFF61758A),
  );
  static final dashColor = AppColorValue(
    dark: Color(0xFFDBE0E5),
    light: Color(0xFFDBE0E5),
  );
}
