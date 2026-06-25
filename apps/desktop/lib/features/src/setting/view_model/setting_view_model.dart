import 'dart:io';

import 'package:data/data.dart';
import 'package:docu_fill/core/core.dart';
import 'package:docu_fill/route/src/routes_path.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:maac_mvvm_annotation/maac_mvvm_annotation.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'setting_view_model.g.dart';

@BindableViewModel()
class SettingViewModel extends BaseViewModel {
  final SettingsRepository _settingsRepository;
  final GeminiService _geminiService;

  SettingViewModel({
    required SettingsRepository settingsRepository,
    required GeminiService geminiService,
  })  : _settingsRepository = settingsRepository,
        _geminiService = geminiService;

  @Bind()
  late final _geminiApiKey = "".mtd(this);

  @Bind()
  late final _selectedModel = "gemini-1.5-flash".mtd(this);

  @Bind()
  late final _geminiStudyData = "".mtd(this);

  @Bind()
  late final _geminiSampleResult = "".mtd(this);

  @Bind()
  late final _enableApiLogging = false.mtd(this);

  static const List<String> _fallbackModels = [
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

  @Bind()
  late final _availableModels = _fallbackModels.mtd(this);

  final TextEditingController apiKeyController = TextEditingController();
  final TextEditingController studyDataController = TextEditingController();
  final TextEditingController sampleResultController = TextEditingController();

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
    final studyData = settings?.geminiStudyData ?? "";
    final sampleResult = settings?.geminiSampleResult ?? "";

    _geminiApiKey.postValue(key);
    _selectedModel.postValue(model);
    _enableApiLogging.postValue(isLogging);
    _geminiStudyData.postValue(studyData);
    _geminiSampleResult.postValue(sampleResult);

    apiKeyController.text = key;
    studyDataController.text = studyData;
    sampleResultController.text = sampleResult;

    await _fetchAvailableModels(key);
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
      final logsPath = p.join(directory.path, 'api_logs');
      final logsDir = Directory(logsPath);
      if (!await logsDir.exists()) {
        await logsDir.create(recursive: true);
      }
      if (Platform.isWindows) {
        await Process.run('explorer.exe', [logsPath]);
      } else if (Platform.isMacOS) {
        await Process.run('open', [logsPath]);
      } else {
        await Process.run('xdg-open', [logsPath]);
      }
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

    // Also save study data and sample result
    await _settingsRepository.saveGeminiTrainingData(
      studyData: studyDataController.text,
      sampleResult: sampleResultController.text,
    );
    _geminiStudyData.postValue(studyDataController.text);
    _geminiSampleResult.postValue(sampleResultController.text);

    await _fetchAvailableModels(apiKeyController.text);

    showSnackbar(AppLang.messagesSettingsSaveSuccess.tr());
  }

  Future<void> _fetchAvailableModels(String key) async {
    if (key.isEmpty) {
      _availableModels.postValue(_fallbackModels);
      return;
    }
    try {
      final models = await _geminiService.getAvailableModels(apiKey: key);
      if (models.isNotEmpty) {
        _availableModels.postValue(models);
      } else {
        _availableModels.postValue(_fallbackModels);
      }
    } catch (e) {
      debugPrint("Failed to fetch models: $e");
      _availableModels.postValue(_fallbackModels);
    }
  }

  @override
  void onDispose() {
    apiKeyController.dispose();
    studyDataController.dispose();
    sampleResultController.dispose();
    super.onDispose();
  }
}
