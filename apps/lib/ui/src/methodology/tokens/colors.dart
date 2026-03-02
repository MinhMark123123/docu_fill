import 'dart:ui';

class AppColorValue {
  final Color dark;
  final Color light;

  AppColorValue({required this.dark, required this.light});
}

class AppColorsDefine {
  AppColorsDefine._();
  static final containerBackground = AppColorValue(
    dark: Color(0xFF0F172A), // Dark slate
    light: Color(0xFFF8FAFC), // Slate 50
  );
  static final buttonBackground = AppColorValue(
    dark: Color(0xFF1E293B), // Slate 800
    light: Color(0xFFF1F5F9), // Slate 100
  );
  static final bodyTextColor = AppColorValue(
    dark: Color(0xFF94A3B8), // Slate 400
    light: Color(0xFF475569), // Slate 600
  );
  static final dashColor = AppColorValue(
    dark: Color(0xFF334155), // Slate 700
    light: Color(0xFFCBD5E1), // Slate 300
  );
  static const primaryBlue = Color(0xFF2563EB); // Modern Blue
  static const primaryIndigo = Color(0xFF4F46E5); // Modern Indigo
}
