import 'dart:convert';
import 'dart:io';

import 'package:data/data.dart';
import 'package:docu_fill/core/core.dart';
import 'package:docu_fill/core/src/events.dart';
import 'package:docu_fill/features/src/home/view_model/home_view_model.dart';
import 'package:docu_fill/route/src/routes_path.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:maac_mvvm_annotation/maac_mvvm_annotation.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'fields_input_view_model.g.dart';

@BindableViewModel()
class FieldsInputViewModel extends BaseViewModel {
  final TemplateRepository _templateRepository;
  final TemplateService _templateService;
  final DataExtractionService _dataExtractionService;
  final GeminiService _geminiService;

  FieldsInputViewModel({
    required TemplateRepository templateRepository,
    required TemplateService templateService,
    required DataExtractionService dataExtractionService,
    required GeminiService geminiService,
  }) : _templateRepository = templateRepository,
       _templateService = templateService,
       _dataExtractionService = dataExtractionService,
       _geminiService = geminiService;

  @Bind()
  late final _templates = List<TemplateConfig>.empty().mtd(this);
  @Bind()
  late final _enableEditNameDoc = false.mtd(this);
  @Bind()
  late final _enableExported = false.mtd(this);
  @Bind()
  late final _directoryExported = "".mtd(this);
  @Bind()
  late final _composedTemplateUI = <String, List<TemplateField>>{}.mtd(this);
  @Bind()
  late final _idsSelected = List<int>.empty().mtd(this);
  @Bind()
  late final _missingKeys = List<String>.empty().mtd(this);
  @Bind()
  late final _currentSectionIndex = 0.mtd(this);
  @Bind()
  late final _showSummary = false.mtd(this);
  @Bind()
  late final _isExportSuccess = false.mtd(this);

  List<String> get sections => _composedTemplateUI.data.keys.toList();

  String get currentSection =>
      sections.isNotEmpty ? sections[_currentSectionIndex.data] : "";

  void updateCurrentSectionIndex(int index) {
    _showSummary.postValue(false);
    _currentSectionIndex.postValue(index);
  }

  void nextSection() {
    if (_currentSectionIndex.data < sections.length - 1) {
      _currentSectionIndex.postValue(_currentSectionIndex.data + 1);
    } else {
      _showSummary.postValue(true);
    }
  }

  void previousSection() {
    if (_showSummary.data) {
      _showSummary.postValue(false);
    } else if (_currentSectionIndex.data > 0) {
      _currentSectionIndex.postValue(_currentSectionIndex.data - 1);
    }
  }

  void goToSummary() => _showSummary.postValue(true);

  final TextEditingController _nameDocExported = TextEditingController();

  TextEditingController get nameDocExported => _nameDocExported;

  final _fieldKeys = <String, String?>{};
  final _singleField = <String, String?>{};

  String? getInitValue({required TemplateField e}) {
    if (e.type == FieldType.selection) {
      return _fieldKeys[e.key] ?? e.options?.firstOrNull;
    }
    if (e.type == FieldType.singleLine) {
      return _singleField[e.key] ?? e.defaultValue;
    }
    return _fieldKeys[e.key] ?? e.defaultValue;
  }

  void performInit(List<int>? ids) {
    _isExportSuccess.postValue(false);
    _idsSelected.postValue(ids ?? []);
    loadTemplates();
  }

  @override
  void onDispose() {
    super.onDispose();
    _nameDocExported.dispose();
  }

  Future<void> _composedUI() async {
    final rawData = _templateService.groupFields(_templates.data);
    _initializeDefaultValues(rawData);

    final localized = _localizeRawData(rawData);
    _composedTemplateUI.postValue(localized);
    checkValidate();
  }

  void _initializeDefaultValues(Map<String?, List<TemplateField>> rawData) {
    for (var fields in rawData.values) {
      for (var field in fields) {
        if (_fieldKeys[field.key] != null) continue;
        final defaultValue = _getDefaultValue(field);
        if (defaultValue != null) {
          setValue(field: field, value: defaultValue, shouldCheckValidate: false);
        }
      }
    }
  }

  String? _getDefaultValue(TemplateField field) {
    if (field.defaultValue?.isNotEmpty == true) return field.defaultValue;
    if (field.type == FieldType.selection) return field.options?.firstOrNull;
    return null;
  }

  Map<String, List<TemplateField>> _localizeRawData(
    Map<String?, List<TemplateField>> rawData,
  ) {
    final hasNamedSections = rawData.keys.any(
      (k) => k != null && k != TemplateService.commonSectionKey,
    );
    final localized = <String, List<TemplateField>>{};

    for (final entry in rawData.entries) {
      if (entry.key != null && entry.key != TemplateService.commonSectionKey) {
        localized[entry.key!] = entry.value;
      }
    }

    if (rawData.containsKey(TemplateService.commonSectionKey)) {
      localized[AppLang.labelsCommon.tr()] =
          rawData[TemplateService.commonSectionKey]!;
    }

    if (rawData.containsKey(null)) {
      final label =
          hasNamedSections
              ? AppLang.labelsGeneralInfo.tr()
              : AppLang.labelsGeneral.tr();
      localized[label] = rawData[null]!;
    }
    return localized;
  }

  Future<void> loadTemplates() async {
    if (_idsSelected.data.isEmpty) {
      _templates.postValue([]);
      return;
    }
    final templates = await Future.wait(
      _idsSelected.data.map((id) => _templateRepository.getTemplateById(id)),
    );
    final safeList = templates.where((element) => element != null).toList();
    _templates.postValue(List<TemplateConfig>.from(safeList));
    await _composedUI();
  }

  void setValue({
    required TemplateField field,
    required String? value,
    bool shouldCheckValidate = true,
  }) {
    if (field.type == FieldType.singleLine) {
      _singleField[field.key] = value;
    } else {
      _fieldKeys[field.key] = value;
    }
    if (shouldCheckValidate) {
      checkValidate();
    }
  }

  Future<void> checkValidate() async {
    final missingKeys = _templateService.validateFields(
      _templates.data,
      _fieldKeys,
    );

    _missingKeys.postValue(missingKeys);
    // Allow editing document name as long as templates are loaded
    _enableEditNameDoc.postValue(_templates.data.isNotEmpty);
    _enableExported.postValue(exportedValid(missingKeys));
  }

  bool exportedValid(Iterable<String> missingKeys) {
    // Export is allowed regardless of missing required keys.
    // The UI will still show the warning about missing keys.
    return _nameDocExported.text.isNotEmpty &&
        _directoryExported.data.isNotEmpty;
  }

  Future<void> exported() async {
    await loadingGuard(
      _templateService.executeExport(
        templates: _templates.data,
        exportDirectory: _directoryExported.data,
        baseFileName: _nameDocExported.text,
        fieldKeys: _fieldKeys,
        singleLines: _singleField,
        composedUI: _composedTemplateUI.data,
      ),
    );
    await Future.delayed(Duration(milliseconds: 200));
    _isExportSuccess.postValue(true);
    doneExported();
  }

  Future<void> exportSummaryText() async {
    if (_directoryExported.data.isEmpty) {
      showSnackbar(AppLang.messagesPickFolderToExport.tr());
      return;
    }
    final fileName =
        _nameDocExported.text.isEmpty ? "export" : _nameDocExported.text;
    await loadingGuard(
      _templateService.exportSummaryText(
        exportDirectory: _directoryExported.data,
        baseFileName: fileName,
        composedUI: _composedTemplateUI.data,
        fieldKeys: _fieldKeys,
        singleLines: _singleField,
      ),
    );
    showSnackbar(AppLang.messagesExportSummarySuccess.tr());
  }

  Future<void> pickFolder() async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      _directoryExported.postValue(result);
    }
    checkValidate();
  }

  void doneExported() {
    _nameDocExported.clear();
    _directoryExported.postValue("");
    _enableExported.postValue(false);
    _enableEditNameDoc.postValue(false);
  }

  void resetAll() {
    _fieldKeys.clear();
    _singleField.clear();
    _idsSelected.postValue([]);
    _templates.postValue([]);
    _composedTemplateUI.postValue({});
    _nameDocExported.clear();
    _directoryExported.postValue("");
    _enableExported.postValue(false);
    _enableEditNameDoc.postValue(false);
    _currentSectionIndex.postValue(0);
    _showSummary.postValue(false);
    _missingKeys.postValue([]);
    _isExportSuccess.postValue(false);

    // Clear selection in HomeViewModel
    getViewModel<HomeViewModel>().clearSelection();

    // Navigate to home to clear the selection in UI
    navigatePage(RoutesPath.home, type: NavigatePageType.replace);
  }

  String getSectionName(String sectionKey) {
    return sectionKey;
  }

  Future<void> useCopy() async {
    await loadingGuard(
      Future(() async {
        try {
          FilePickerResult? result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['json'],
          );
          if (result == null || result.files.single.path == null) return;

          final file = File(result.files.single.path!);
          final String content = await file.readAsString();
          final Map<String, dynamic> data = jsonDecode(content);

          _applyDataToForm(data);
          showSnackbar(AppLang.actionsLoadCopySuccess.tr());
        } catch (e) {
          debugPrint("Error using copy: $e");
          showSnackbar(AppLang.actionsLoadCopyError.tr());
        }
      }),
    );
  }

  Future<void> importFromFile() async {
    try {
      final path = await _pickImportFile();
      if (path == null) return;

      await loadingGuard(_processFileImport(File(path)));
    } catch (e) {
      debugPrint("Error importing from file: $e");
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      showSnackbar("${AppLang.labelsError.tr()}: $errorMessage");
    }
  }

  Future<String?> _pickImportFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'xlsx', 'xls'],
    );
    return result?.files.single.path;
  }

  Future<void> _processFileImport(File file) async {
    final extraction = await _extractTextSafely(file);
    final mappedData = await _mapFileToTemplate(file, extraction);

    await _autoSaveAiResult(
      sourceFileName: p.basename(file.path),
      resultData: mappedData,
    );

    _applyAiDataToForm(mappedData);
    showSnackbar(AppLang.messagesImportFromFileSuccess.tr());
  }

  Future<({String text, bool pdfError})> _extractTextSafely(File file) async {
    try {
      final text = await _dataExtractionService.extractText(file);
      if (text.isEmpty) throw Exception(AppLang.messagesExtractNoText.tr());
      return (text: text, pdfError: false);
    } catch (e) {
      if (e.toString().toLowerCase().contains("pdf")) {
        return (text: "", pdfError: true);
      }
      rethrow;
    }
  }

  Future<Map<String, String>> _mapFileToTemplate(
    File file,
    ({String text, bool pdfError}) extraction,
  ) async {
    final allFields = _templates.data.expand((t) => t.fields).toList();
    final templateConfig = {for (var f in allFields) f.key: f.description};

    if (extraction.pdfError) {
      return _geminiService.mapFileToTemplate(
        fileBytes: await file.readAsBytes(),
        fileName: p.basename(file.path),
        templateConfig: templateConfig,
      );
    }
    return _geminiService.mapTextToTemplate(
      rawText: extraction.text,
      templateConfig: templateConfig,
    );
  }

  /// Automatically saves the AI analysis result to a local JSON file
  Future<void> _autoSaveAiResult({
    required String sourceFileName,
    required Map<String, String> resultData,
  }) async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      // Use p.join for OS-native path separators
      final aiResultsDirPath = p.join(appDocDir.path, "ai_results");
      final aiResultsDir = Directory(aiResultsDirPath);
      if (!await aiResultsDir.exists()) {
        await aiResultsDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final resultFileName = "ai_res_${sourceFileName}_$timestamp.json";
      final resultFile = File(p.join(aiResultsDirPath, resultFileName));

      await resultFile.writeAsString(jsonEncode(resultData));
      debugPrint("AI Result auto-saved: ${resultFile.path}");
    } catch (e) {
      debugPrint("Error auto-saving AI result: $e");
    }
  }

  /// Loads and applies a previously saved AI analysis result
  void applyAiResult(Map<String, String> mappedData) {
    _applyAiDataToForm(mappedData);
    showSnackbar(AppLang.messagesImportFromFileSuccess.tr());
  }


  void _applyAiDataToForm(Map<String, String> mappedData) {
    final cloned = Map<String, List<TemplateField>>.from(
      _composedTemplateUI.data,
    );
    _composedTemplateUI.postValue(<String, List<TemplateField>>{});

    final allFields = _templates.data.expand((t) => t.fields).toList();
    for (var field in allFields) {
      final value = mappedData[field.key];
      if (value != null && value.isNotEmpty) {
        if (field.type == FieldType.singleLine) {
          _singleField[field.key] = value;
        } else {
          _fieldKeys[field.key] = value;
        }
      }
    }

    _composedTemplateUI.postValue(cloned);
    checkValidate();
  }

  void _applyDataToForm(Map<String, dynamic> data) {
    final cloned = Map<String, List<TemplateField>>.from(
      _composedTemplateUI.data,
    );
    _composedTemplateUI.postValue(<String, List<TemplateField>>{});

    if (data['fields'] != null) {
      final fields = Map<String, dynamic>.from(data['fields']);
      fields.forEach((key, value) {
        if (value != null) _fieldKeys[key] = value.toString();
      });
    }

    if (data['singleLines'] != null) {
      final singles = Map<String, dynamic>.from(data['singleLines']);
      singles.forEach((key, value) {
        if (value != null) _singleField[key] = value.toString();
      });
    }

    _composedTemplateUI.postValue(cloned);
    checkValidate();
  }

  Future<void> createCopy() async {
    try {
      final imageKeys = <String>{};
      for (var template in _templates.data) {
        for (var field in template.fields) {
          if (field.type == FieldType.image) {
            imageKeys.add(field.key);
          }
        }
      }

      final jsonString = _templateService.createCopyData(
        fieldKeys: _fieldKeys,
        singleField: _singleField,
        imageKeys: imageKeys,
      );

      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: AppLang.actionsSaveCopyTitle.tr(),
        fileName: 'copy_${DateTime.now().millisecondsSinceEpoch}.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsString(jsonString);
        showSnackbar(AppLang.actionsCreateCopySuccess.tr());
      }
    } catch (e) {
      debugPrint("Error creating copy: $e");
      showSnackbar(AppLang.actionsCreateCopyError.tr(args: [e.toString()]));
    }
  }
}
