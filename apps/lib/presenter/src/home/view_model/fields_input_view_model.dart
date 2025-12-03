import 'dart:io';

import 'package:docu_fill/const/src/app_const.dart';
import 'package:docu_fill/core/core.dart';
import 'package:docu_fill/data/data.dart';
import 'package:docu_fill/data/src/dimensions.dart';
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
  @Bind()
  late final _idsSelected = List<int>.empty().mtd(this);

  final TextEditingController _nameDocExported = TextEditingController();

  TextEditingController get nameDocExported => _nameDocExported;

  final _fieldKeys = <String, String?>{};
  final _singleField = <String, String?>{};

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
    final rawData = <int, List<TemplateField>>{};
    if (_templates.data.length == 1) {
      final template = _templates.data.first;
      for (var field in template.fields) {
        if (field.defaultValue != null && field.defaultValue!.isNotEmpty) {
          setValue(field: field, value: field.defaultValue);
        }
        if (field.type == FieldType.selection) {
          setValue(field: field, value: field.options?.firstOrNull);
        }
      }
      rawData[template.id] = template.fields;
      _composedTemplateUI.postValue(rawData);
      return;
    }
    rawData[AppConst.commonUnknow] = [];
    for (var template in _templates.data) {
      final fields = template.fields;
      rawData[template.id] = fields;

      for (var field in fields) {
        if (field.defaultValue != null && field.defaultValue!.isNotEmpty) {
          setValue(field: field, value: field.defaultValue);
        }
        if (field.type == FieldType.selection) {
          setValue(field: field, value: field.options?.firstOrNull);
        }
        if (!rawData[AppConst.commonUnknow]!.contains(field)) {
          rawData[AppConst.commonUnknow]!.add(field);
          rawData[AppConst.commonUnknow]!.remove(field);
        }
      }
    }
    _composedTemplateUI.postValue(rawData);
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
    final imageReplacements = getImageReplacements(nonNullAbleMap);
    await loadingGuard(
      _executedExport(
        nonNullAbleMap: nonNullAbleMap,
        imageReplacements: imageReplacements,
        singleLines: _singleField,
      ),
    );
    await Future.delayed(Duration(milliseconds: 200));
    doneExported();
  }

  Future<void> _executedExport({
    required Map<String, String> nonNullAbleMap,
    required Map<String, (String, Size)> imageReplacements,
    required Map<String, String?> singleLines,
  }) async {
    for (var template in _templates.data) {
      await _executeSingleTemplate(
        template: template,
        nonNullAbleMap: nonNullAbleMap,
        imageReplacements: imageReplacements,
        singleLines: singleLines,
      );
    }
    await Future.delayed(Duration(seconds: 2));
  }

  Future<void> _executeSingleTemplate({
    required TemplateConfig template,
    required Map<String, String> nonNullAbleMap,
    required Map<String, (String, Size)> imageReplacements,
    required Map<String, String?> singleLines,
  }) async {
    final fileOrigin = File(template.pathTemplate);
    final originalBytes = await fileOrigin.readAsBytes();
    final rawBytes = await DocxUtils.composeModifiedDocxWithPlaceholders(
      originalBytes: originalBytes,
      replacements: nonNullAbleMap,
      imageReplacements: imageReplacements,
      singleLines: singleLines,
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
    final fields = <TemplateField>[];
    for (var template in _templates.data) {
      fields.addAll(template.fields);
    }
    for (var element in fields) {
      final valueInput = _fieldKeys[element.key];
      if (element.type == FieldType.datetime && valueInput != null) {
        final format = element.additionalInfo;
        if (format != null && format.isNotEmpty) {
          setValue(
            field: element,
            value: DateTimeUtils.format(valueInput, format: format),
            shouldCheckValidate: false,
          );
        }
      }
      if (_fieldKeys[element.key] == null) {
        setValue(field: element, value: element.defaultValue ?? "");
        setValue(
          field: element,
          value: element.defaultValue ?? "",
          shouldCheckValidate: false,
        );
      }
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
    _singleField.clear();
    _nameDocExported.clear();
    _directoryExported.postValue("");
    _enableExported.postValue(false);
    _enableEditNameDoc.postValue(false);
  }

  String getTemplateName(int templateId) {
    if (_templates.data.isEmpty) return AppConst.empty;
    return _templates.data.firstWhere((e) => e.id == templateId).templateName;
  }

  Map<String, (String, Size)> getImageReplacements(
    Map<String, String> nonNullAbleMap,
  ) {
    List<TemplateField> raw = [];
    for (var e in _composedTemplateUI.data.values) {
      raw.addAll(e);
    }
    final imageField = raw.where((e) => e.type == FieldType.image);
    final result = <String, (String, Size)>{};
    //clear image field
    for (var e in imageField) {
      final key = e.key;
      final dimension = Dimensions.from(e.additionalInfo);
      final size = dimension?.toInches();
      if (dimension != null && nonNullAbleMap[key] != null && size != null) {
        result[key] = (nonNullAbleMap[key]!, size);
      }
      nonNullAbleMap.remove(e.key);
    }
    return result;
  }
}
