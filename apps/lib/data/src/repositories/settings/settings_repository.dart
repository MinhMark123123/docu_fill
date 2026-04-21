import 'package:docu_fill/data/data.dart';
import 'package:docu_fill/data/src/entities/app_settings_model.dart';
import 'package:isar_community/isar.dart';

abstract class SettingsRepository {
  Future<AppSettingsModel?> getSettings();
  Future<void> saveGeminiApiKey(String apiKey);
}

class SettingsRepositoryImpl implements SettingsRepository {
  final Isar _isar;

  SettingsRepositoryImpl(this._isar);

  @override
  Future<AppSettingsModel?> getSettings() async {
    return await _isar.appSettingsModels.where().findFirst();
  }

  @override
  Future<void> saveGeminiApiKey(String apiKey) async {
    final settings = await getSettings() ?? AppSettingsModel();
    settings.geminiApiKey = apiKey;
    await _isar.writeTxn(() async {
      await _isar.appSettingsModels.put(settings);
    });
  }
}
