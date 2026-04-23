import 'package:localization/localization.dart';
import 'dart:io';

import 'package:docu_fill/core/core.dart';
import 'package:data/data.dart';
import 'package:docu_fill/route/src/routes_path.dart';
import 'package:flutter/material.dart';
import 'package:maac_mvvm_annotation/maac_mvvm_annotation.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';
import 'package:path_provider/path_provider.dart';

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

  @Bind()
  late final _enableApiLogging = false.mtd(this);

  List<String> get availableModels => [
    'gemini-3.1-pro-preview',
    'gemini-3-flash-preview',
    'gemini-3.1-flash-lite-preview',
    'gemini-2.5-pro',
    'gemini-2.5-flash',
    'gemini-2.5-flash-lite',
    'gemini-1.5-pro',
    'gemini-1.5-flash',
    'gemini-1.5-flash-8b',
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
    final isLogging = settings?.enableApiLogging ?? false;
    _geminiApiKey.postValue(key);
    _selectedModel.postValue(model);
    _enableApiLogging.postValue(isLogging);
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

  Future<void> onToggleApiLogging(bool enabled) async {
    _enableApiLogging.postValue(enabled);
    await _settingsRepository.saveApiLoggingSetting(enabled);
  }

  Future<void> openLogsFolder() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logsPath = "${directory.path}/api_logs";
      final logsDir = Directory(logsPath);
      if (!await logsDir.exists()) {
        await logsDir.create(recursive: true);
      }
      // Use Process.run to open the folder on macOS
      await Process.run('open', [logsPath]);
    } catch (e) {
      showSnackbar("Could not open logs folder: $e");
    }
  }

  void navigateToLogHistory(BuildContext context) {
    final path = "${RoutesPath.setting}/${RoutesPath.logHistory}";
    navigatePage(path);
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
