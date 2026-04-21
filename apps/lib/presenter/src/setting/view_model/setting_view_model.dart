import 'package:docu_fill/const/const.dart';
import 'package:docu_fill/core/core.dart';
import 'package:docu_fill/data/src/repositories/settings/settings_repository.dart';
import 'package:docu_fill/utils/utils.dart';
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

  @Bind()
  late final _selectedModel = "gemini-1.5-flash".mtd(this);

  List<String> get availableModels => [
    'gemini-1.5-flash',
    'gemini-1.5-pro',
    'gemini-2.0-flash',
    'gemini-3-flash-preview',
  ];

  final TextEditingController apiKeyController = TextEditingController();

  @override
  void onInitState() {
    super.onInitState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final settings = await _settingsRepository.getSettings();
    final key = settings?.geminiApiKey ?? "";
    final model = settings?.geminiModel ?? "gemini-1.5-flash";
    _geminiApiKey.postValue(key);
    _selectedModel.postValue(model);
    apiKeyController.text = key;
  }

  Future<void> changeLocale(BuildContext context, Locale locale) async {
    await context.setLocale(locale);
    await _settingsRepository.saveLocale(
      locale.languageCode,
      locale.countryCode ?? "",
    );
  }

  Future<void> onModelSelected(String? model) async {
    if (model == null) return;
    _selectedModel.postValue(model);
    await _settingsRepository.saveGeminiModel(model);
  }

  Future<void> saveGeminiApiKey() async {
    if (apiKeyController.text.isEmpty) {
      showSnackbar(AppLang.messagesGeminiApiKeyRequired.tr());
      return;
    }
    await _settingsRepository.saveGeminiApiKey(apiKeyController.text);
    _geminiApiKey.postValue(apiKeyController.text);
    showSnackbar(AppLang.messagesSettingsSaveSuccess.tr());
  }

  @override
  void onDispose() {
    apiKeyController.dispose();
    super.onDispose();
  }
}
