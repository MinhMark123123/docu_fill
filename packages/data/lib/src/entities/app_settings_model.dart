import 'package:isar_community/isar.dart';

part 'app_settings_model.g.dart';

@collection
class AppSettingsModel {
  Id id = Isar.autoIncrement;

  String? geminiApiKey;
  String? geminiModel;
  String? geminiStudyData;
  String? geminiSampleResult;
  bool enableApiLogging = false;
  String? languageCode;
  String? countryCode;

  /// "offline" or "gemini"; null = offline when the engine is installed.
  String? mappingEngine;

  /// Ask the local LLM for fields the learned rules leave empty (slow on CPU).
  bool useLocalLlm = false;

  // You can add more settings here in the future
}
