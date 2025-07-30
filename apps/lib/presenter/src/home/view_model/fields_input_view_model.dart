import 'dart:io';

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
  late final _template = TemplateConfig.none().mtd(this);
  @Bind()
  late final _enableEditNameDoc = false.mtd(this);
  @Bind()
  late final _enableExported = false.mtd(this);
  @Bind()
  late final _directoryExported = "".mtd(this);

  final TextEditingController _nameDocExported = TextEditingController();

  TextEditingController get nameDocExported => _nameDocExported;

  int _id = -1;
  final _fieldKeys = <String, String?>{};

  void setup(int id) {
    _id = id;
    loadTemplates();
  }

  @override
  void onDispose() {
    super.onDispose();
    _nameDocExported.dispose();
  }

  Future<void> loadTemplates() async {
    if (_id == -1) {
      _template.postValue(TemplateConfig.none());
      return;
    }
    final template = await _templateRepository.getTemplateById(_id);
    if (template == null) return;
    _template.postValue(template);
    _initFirstValueSelection();
  }

  void _initFirstValueSelection() {
    final selectionsField = _template.data.fields.where(
      (e) => e.type == FieldType.selection,
    );
    for (var e in selectionsField) {
      _fieldKeys[e.key] = e.options?.firstOrNull;
    }
  }

  void setValue({required String key, required String? value}) {
    _fieldKeys[key] = value;
    checkValidate();
  }

  Future<void> checkValidate() async {
    final requiredKeys =
        _template.data.fields
            .where((element) => element.required)
            .map((e) => e.key)
            .toList();
    final missingKeys = requiredKeys.where((key) => _fieldKeys[key] == null);
    _enableEditNameDoc.postValue(missingKeys.isEmpty);
    _enableExported.postValue(
      missingKeys.isEmpty &&
          _nameDocExported.text.isNotEmpty &&
          _directoryExported.data.isNotEmpty,
    );
  }

  Future<void> exported(BuildContext context) async {
    final nonNullAbleMap = prettyData();
    await loadingGuard(_executedExport(nonNullAbleMap));
    await Future.delayed(Duration(milliseconds: 200));
    doneExported();
  }

  Future<void> _executedExport(Map<String, String> nonNullAbleMap) async {
    final fileOrigin = File(_template.data.pathTemplate);
    final originalBytes = await fileOrigin.readAsBytes();
    final rawBytes = DocxUtils.composeModifiedDocxWithPlaceholders(
      originalBytes,
      nonNullAbleMap,
    );
    final mimeType = _template.data.pathTemplate.split(".").lastOrNull;
    final fileName = "${_nameDocExported.text}.$mimeType";
    final fileDir = _directoryExported.data;
    final filePath = "$fileDir${Platform.pathSeparator}$fileName";
    final targetFile = File(filePath);
    if (!targetFile.existsSync()) {
      targetFile.createSync(recursive: true);
    }
    targetFile.writeAsBytesSync(rawBytes);
    await Future.delayed(Duration(seconds: 2));
  }

  Map<String, String> prettyData() {
    for (var element in _template.data.fields) {
      if (_fieldKeys[element.key] == null) {
        _fieldKeys[element.key] = element.defaultValue ?? "";
      }
    }
    final nullKeys = _fieldKeys.keys.where((key) => _fieldKeys[key] == null);
    for (var key in nullKeys) {
      _fieldKeys[key] =
          _template.data.fields
              .firstWhere((element) => element.key == key)
              .defaultValue;
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
    _template.postValue(TemplateConfig.none());
    _fieldKeys.clear();
    _nameDocExported.clear();
    _directoryExported.postValue("");
    _enableExported.postValue(false);
    _enableEditNameDoc.postValue(false);
  }
}
