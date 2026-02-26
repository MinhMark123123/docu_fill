import 'dart:io';

import 'package:docu_fill/const/const.dart';
import 'package:docu_fill/core/core.dart';
import 'package:docu_fill/data/data.dart';
import 'package:docu_fill/utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:maac_mvvm_annotation/maac_mvvm_annotation.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

part 'fields_input_view_model.g.dart';

@BindableViewModel()
class FieldsInputViewModel extends BaseViewModel {
  final TemplateRepository _templateRepository;
  final TemplateService _templateService;

  FieldsInputViewModel({
    required TemplateRepository templateRepository,
    required TemplateService templateService,
  }) : _templateRepository = templateRepository,
       _templateService = templateService;

  @Bind()
  late final _templates = List<TemplateConfig>.empty().mtd(this);
  @Bind()
  late final _enableEditNameDoc = false.mtd(this);
  @Bind()
  late final _enableExported = false.mtd(this);
  @Bind()
  late final _directoryExported = "".mtd(this);
  @Bind()
  late final _composedTemplateUI = <int, List<TemplateField>>{}.mtd(this);
  @Bind()
  late final _idsSelected = List<int>.empty().mtd(this);
  @Bind()
  late final _missingKeys = List<String>.empty().mtd(this);

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

    _composedTemplateUI.postValue(rawData);
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
      debugPrint("set value single line ${field.key}: $value");
    } else {
      debugPrint("set value ${field.key}: $value");
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
    _enableEditNameDoc.postValue(missingKeys.isEmpty);
    _enableExported.postValue(exportedValid(missingKeys));
  }

  bool exportedValid(Iterable<String> missingKeys) {
    return missingKeys.isEmpty &&
        _nameDocExported.text.isNotEmpty &&
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

  String getTemplateName(int templateId) {
    if (_templates.data.isEmpty) return AppConst.empty;
    return _templates.data.firstWhere((e) => e.id == templateId).templateName;
  }

  Future<void> useCopy() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null || result.files.single.path == null) return;

      final cloned = Map<int, List<TemplateField>>.from(
        _composedTemplateUI.data,
      );
      _composedTemplateUI.postValue(<int, List<TemplateField>>{});

      final file = File(result.files.single.path!);
      final String content = await file.readAsString();
      final Map<String, dynamic> data = _templateService.parseCopyData(content);

      final listTemplates = <TemplateField>[];
      final currentKeys = cloned.values.fold(listTemplates, (a, b) {
        a.addAll(b);
        return a;
      });
      final keysCompare = currentKeys.asMap().map(
        (key, e) => MapEntry(e.key, e),
      );

      if (data['fields'] != null) {
        final fields = Map<String, dynamic>.from(data['fields']);
        fields.forEach((key, value) {
          if (value != null && keysCompare.containsKey(key)) {
            _fieldKeys[key] = value.toString();
          }
        });
      }

      if (data['singleLines'] != null) {
        final singles = Map<String, dynamic>.from(data['singleLines']);
        singles.forEach((key, value) {
          if (value != null && keysCompare.containsKey(key)) {
            _singleField[key] = value.toString();
          }
        });
      }
      _composedTemplateUI.postValue(cloned);
      await checkValidate();
      showSnackbar(AppLang.loadCopySuccess.tr());
    } catch (e) {
      debugPrint("Error using copy: $e");
      showSnackbar(AppLang.loadCopyError.tr());
    }
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
        dialogTitle: AppLang.saveCopyTitle.tr(),
        fileName: 'copy_${DateTime.now().millisecondsSinceEpoch}.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsString(jsonString);
        showSnackbar(AppLang.createCopySuccess.tr());
      }
    } catch (e) {
      debugPrint("Error creating copy: $e");
      showSnackbar(AppLang.createCopyError.tr(args: [e.toString()]));
    }
  }
}
