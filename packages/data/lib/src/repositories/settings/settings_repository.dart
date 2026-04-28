import 'package:data/data.dart';
import 'package:data/src/entities/app_settings_model.dart';
import 'package:isar_community/isar.dart';

abstract class SettingsRepository {
  Future<AppSettingsModel?> getSettings();
  Future<void> saveSettings(AppSettingsModel settings);
  Future<void> saveGeminiApiKey(String apiKey);
  Future<void> saveGeminiModel(String model);
  Future<void> saveGeminiTrainingData({String? studyData, String? sampleResult});
  Future<void> saveApiLoggingSetting(bool enabled);
  Future<void> saveLocale(String languageCode, String countryCode);
}

class SettingsRepositoryImpl implements SettingsRepository {
  final Isar _isar;

  SettingsRepositoryImpl(this._isar);

  @override
  Future<AppSettingsModel?> getSettings() async {
    return await _isar.appSettingsModels.where().findFirst();
  }

  @override
  Future<void> saveSettings(AppSettingsModel settings) async {
    await _isar.writeTxn(() async {
      await _isar.appSettingsModels.put(settings);
    });
  }

  @override
  Future<void> saveGeminiApiKey(String apiKey) async {
    final settings = await getSettings() ?? AppSettingsModel();
    settings.geminiApiKey = apiKey;
    await saveSettings(settings);
  }

  @override
  Future<void> saveGeminiModel(String model) async {
    final settings = await getSettings() ?? AppSettingsModel();
    settings.geminiModel = model;
    await saveSettings(settings);
  }

  @override
  Future<void> saveGeminiTrainingData({
    String? studyData,
    String? sampleResult,
  }) async {
    final settings = await getSettings() ?? AppSettingsModel();
    if (studyData != null) settings.geminiStudyData = studyData;
    if (sampleResult != null) settings.geminiSampleResult = sampleResult;
    await saveSettings(settings);
  }

  @override
  Future<void> saveApiLoggingSetting(bool enabled) async {
    final settings = await getSettings() ?? AppSettingsModel();
    settings.enableApiLogging = enabled;
    await saveSettings(settings);
  }

  @override
  Future<void> saveLocale(String languageCode, String countryCode) async {
    final settings = await getSettings() ?? AppSettingsModel();
    settings.languageCode = languageCode;
    settings.countryCode = countryCode;
    await saveSettings(settings);
  }
}
