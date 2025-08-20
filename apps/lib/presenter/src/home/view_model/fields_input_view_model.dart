import 'dart:io';

import 'package:docu_fill/const/src/app_const.dart';
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

  FieldsInputViewModel({required TemplateRepository templateRepository})
    : _templateRepository = templateRepository;

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

  final TextEditingController _nameDocExported = TextEditingController();

  TextEditingController get nameDocExported => _nameDocExported;

  List<int> _idsSelected = [];
  final _fieldKeys = <String, String?>{};

  void setup(List<int> ids) {
    _idsSelected = ids;
    loadTemplates();
  }

  @override
  void onDispose() {
    super.onDispose();
    _nameDocExported.dispose();
  }

  Future<void> loadTemplates() async {
    if (_idsSelected.isEmpty) {
      _templates.postValue([]);
      return;
    }
    for (var id in _idsSelected) {
      final template = await _templateRepository.getTemplateById(id);
      if (template != null) {
        _templates.postValue([template]);
      }
    }
    await _composedUI();

    _initFirstValueSelection();
  }

  Future<void> _composedUI() async {
    final rawData = <int, List<TemplateField>>{};
    if (_templates.data.length == 1) {
      final template = _templates.data.first;
      rawData[template.id] = template.fields;
      _composedTemplateUI.postValue(rawData);
      return;
    }
    rawData[AppConst.commonUnknow] = [];
    for (var template in _templates.data) {
      final fields = template.fields;
      rawData[template.id] = fields;
      for (var field in fields) {
        if (!rawData[AppConst.commonUnknow]!.contains(field)) {
          rawData[AppConst.commonUnknow]!.add(field);
          rawData[AppConst.commonUnknow]!.remove(field);
        }
      }
    }
    _composedTemplateUI.postValue(rawData);
  }

  void _initFirstValueSelection() {
    for (var template in _templates.data) {
      final selectionsField = template.fields.where(
        (e) => e.type == FieldType.selection,
      );
      for (var e in selectionsField) {
        _fieldKeys[e.key] = e.options?.firstOrNull;
      }
    }
  }

  void setValue({required String key, required String? value}) {
    _fieldKeys[key] = value;
    checkValidate();
  }

  Future<void> checkValidate() async {
    final requiredKeys = List<String>.empty(growable: true);

    for (var template in _templates.data) {
      final rawFields = template.fields
          .where((element) => element.required)
          .map((e) => e.key);
      final childRequired = rawFields.toList();
      requiredKeys.addAll(childRequired);
    }
    final missingKeys = requiredKeys.where((key) => _fieldKeys[key] == null);
    _enableEditNameDoc.postValue(missingKeys.isEmpty);
    _enableExported.postValue(exportedValid(missingKeys));
  }

  bool exportedValid(Iterable<String> missingKeys) {
    return missingKeys.isEmpty &&
        _nameDocExported.text.isNotEmpty &&
        _directoryExported.data.isNotEmpty;
  }

  Future<void> exported(BuildContext context) async {
    final nonNullAbleMap = prettyData();
    await loadingGuard(_executedExport(nonNullAbleMap));
    await Future.delayed(Duration(milliseconds: 200));
    doneExported();
  }

  Future<void> _executedExport(Map<String, String> nonNullAbleMap) async {
    for (var template in _templates.data) {
      await _executeSingleTemplate(
        template: template,
        nonNullAbleMap: nonNullAbleMap,
      );
    }
    await Future.delayed(Duration(seconds: 2));
  }

  Future<void> _executeSingleTemplate({
    required TemplateConfig template,
    required Map<String, String> nonNullAbleMap,
  }) async {
    final fileOrigin = File(template.pathTemplate);
    final originalBytes = await fileOrigin.readAsBytes();
    final rawBytes = await DocxUtils.composeModifiedDocxWithPlaceholders(
      originalBytes: originalBytes,
      replacements: nonNullAbleMap,
    );
    final mimeType = template.pathTemplate.split(".").lastOrNull;
    final fileName = "${_nameDocExported.text}.$mimeType";
    final fileDir = _directoryExported.data;
    final filePath = "$fileDir${Platform.pathSeparator}$fileName";
    final targetFile = File(filePath);
    if (!targetFile.existsSync()) {
      targetFile.createSync(recursive: true);
    }
    targetFile.writeAsBytesSync(rawBytes);
  }

  Map<String, String> prettyData() {
    final fields = [];
    for (var template in _templates.data) {
      fields.addAll(template.fields);
    }
    for (var element in fields) {
      if (_fieldKeys[element.key] == null) {
        _fieldKeys[element.key] = element.defaultValue ?? "";
      }
    }
    final nullKeys = _fieldKeys.keys.where((key) => _fieldKeys[key] == null);
    for (var key in nullKeys) {
      _fieldKeys[key] =
          fields.firstWhere((element) => element.key == key).defaultValue;
    }
    return _fieldKeys.map((key, value) => MapEntry(key, value!));
  }

  Future<void> pickFolder() async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      _directoryExported.postValue(result);
    }
  }

  void doneExported() {
    _templates.postValue([]);
    _fieldKeys.clear();
    _nameDocExported.clear();
    _directoryExported.postValue("");
    _enableExported.postValue(false);
    _enableEditNameDoc.postValue(false);
  }

  String getTemplateName(int templateId) {
    return _templates.data.firstWhere((e) => e.id == templateId).templateName;
  }
}
