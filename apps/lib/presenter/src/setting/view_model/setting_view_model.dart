import 'package:docu_fill/core/core.dart';
import 'package:docu_fill/data/src/repositories/settings/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:maac_mvvm_annotation/maac_mvvm_annotation.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

part 'setting_view_model.g.dart';

@BindableViewModel()
class SettingViewModel extends BaseViewModel {
  final SettingsRepository _settingsRepository;

  SettingViewModel({required SettingsRepository settingsRepository})
      : _settingsRepository = settingsRepository;

  @Bind()
  late final _geminiApiKey = "".mtd(this);

  final TextEditingController apiKeyController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final settings = await _settingsRepository.getSettings();
    final key = settings?.geminiApiKey ?? "";
    _geminiApiKey.postValue(key);
    apiKeyController.text = key;
  }

  Future<void> saveSettings() async {
    await _settingsRepository.saveGeminiApiKey(apiKeyController.text);
    _geminiApiKey.postValue(apiKeyController.text);
    showSnackbar("Settings saved successfully!");
  }

  @override
  void onDispose() {
    apiKeyController.dispose();
    super.onDispose();
  }
}
