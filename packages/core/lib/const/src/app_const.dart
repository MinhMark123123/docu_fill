import 'dart:ui';

class AppConst {
  AppConst._();
  static const placeHolderRegex = r'\%\%(.*?)\%\%';
  static const documentColor = Color(0xFFE0DACE);
  static const int commonUnknow = -1;
  static const String commonKey = "commonKey";
  static const String empty = "";
  static const String settingFileExtension = ".dfconf";
  static const String settingJsonFileName = "config.json"; // Changed to config.json for clarity if needed
  static const String settingDocFileName = "template_file";

  static String composeKey({required String key}) => '''%%$key%%''';
}
