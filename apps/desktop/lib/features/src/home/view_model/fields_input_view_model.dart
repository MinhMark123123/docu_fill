import 'dart:convert';
import 'dart:io';

import 'package:data/data.dart';
import 'package:docu_fill/core/core.dart';
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

    // Initialize defaults for all groups
    for (var fields in rawData.values) {
      for (var field in fields) {
        if (_fieldKeys[field.key] == null) {
          if (field.defaultValue?.isNotEmpty == true) {
            setValue(
              field: field,
              value: field.defaultValue,
              shouldCheckValidate: false,
            );
          } else if (field.type == FieldType.selection) {
            setValue(
              field: field,
              value: field.options?.firstOrNull,
              shouldCheckValidate: false,
            );
          }
        }
      }
    }

    final hasNamedSections = rawData.keys.any(
      (k) => k != null && k != TemplateService.commonSectionKey,
    );

    final localized = <String, List<TemplateField>>{};

    // Named sections
    for (final entry in rawData.entries) {
      if (entry.key == null || entry.key == TemplateService.commonSectionKey) {
        continue;
      }
      localized[entry.key!] = entry.value;
    }

    // Put "common" bucket when it exists
    if (rawData.containsKey(TemplateService.commonSectionKey)) {
      localized[AppLang.labelsCommon.tr()] =
          rawData[TemplateService.commonSectionKey]!;
    }
    // Unsectioned fields (null key)
    if (rawData.containsKey(null)) {
      final label =
          hasNamedSections
              ? AppLang.labelsGeneralInfo
                  .tr() // coexists with named sections
              : AppLang.labelsGeneral.tr(); // only group → keep it simple
      localized[label] = rawData[null]!;
    }
    _composedTemplateUI.postValue(localized);
    checkValidate();
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
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'xlsx', 'xls'],
      );
      if (result == null || result.files.single.path == null) return;

      await loadingGuard(
        Future(() async {
          final file = File(result.files.single.path!);
          String extractedText = "";
          bool pdfError = false;
          try {
            extractedText = await _dataExtractionService.extractText(file);
          } catch (e) {
            if (e.toString().toLowerCase().contains("pdf")) {
              pdfError = true;
            } else {
              rethrow;
            }
          }

          if (extractedText.isEmpty && !pdfError) {
            throw Exception(AppLang.messagesExtractNoText.tr());
          }

          final allFields = _templates.data.expand((t) => t.fields).toList();
          final templateConfig = {
            for (var f in allFields) f.key: f.description,
          };

          final mappedData =
              pdfError
                  ? await _geminiService.mapFileToTemplate(
                    fileBytes: await file.readAsBytes(),
                    fileName: file.path.split(Platform.pathSeparator).last,
                    templateConfig: templateConfig,
                  )
                  : await _geminiService.mapTextToTemplate(
                    rawText: extractedText,
                    templateConfig: templateConfig,
                  );

          // AUTO-SAVE AI RESULT for future use
          await _autoSaveAiResult(
            sourceFileName: file.path.split(Platform.pathSeparator).last,
            resultData: mappedData,
          );

          _applyAiDataToForm(mappedData);
          showSnackbar(AppLang.messagesImportFromFileSuccess.tr());
        }),
      );
    } catch (e) {
      debugPrint("Error importing from file: $e");
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      showSnackbar("${AppLang.labelsError.tr()}: $errorMessage");
    }
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
  Future<void> importAiResult() async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final aiResultsDirPath = p.join(appDocDir.path, "ai_results");
      final aiResultsDir = Directory(aiResultsDirPath);
      if (!await aiResultsDir.exists()) {
        await aiResultsDir.create(recursive: true);
      }

      final files =
          await aiResultsDir
              .list()
              .where((e) => e is File && e.path.endsWith('.json'))
              .cast<File>()
              .toList();

      if (files.isEmpty) {
        showSnackbar(
          AppLang.messagesExtractNoText.tr(),
        ); // Or another appropriate message
        return;
      }

      // Sort by last modified date (newest first)
      files.sort(
        (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
      );

      final fileNames = files.map((f) => p.basename(f.path)).toList();
      final selectedIndex = await showSelectionDialog(
        title: AppLang.messagesSelectFromAiResults.tr(),
        options: fileNames,
      );

      if (selectedIndex == null) return;

      final selectedFile = files[selectedIndex];
      final String content = await selectedFile.readAsString();
      final Map<String, dynamic> data = jsonDecode(content);
      final mappedData = data.map(
        (key, value) => MapEntry(key, value.toString()),
      );

      _applyAiDataToForm(mappedData);
      showSnackbar(AppLang.messagesImportFromFileSuccess.tr());
    } catch (e) {
      debugPrint("Error importing AI result: $e");
      showSnackbar(AppLang.actionsLoadCopyError.tr());
    }
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
