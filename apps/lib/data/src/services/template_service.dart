import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:archive/archive.dart';
import 'package:docu_fill/const/const.dart';
import 'package:docu_fill/data/data.dart';
import 'package:docu_fill/utils/utils.dart';

class TemplateService {
  final TemplateRepository _templateRepository;

  TemplateService({required TemplateRepository templateRepository})
    : _templateRepository = templateRepository;

  Future<void> deleteTemplate(TemplateConfig item) async {
    await _templateRepository.deleteTemplate(item.id);
    final file = File(item.pathTemplate);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  Future<List<int>?> createExportArchive(TemplateConfig item) async {
    final archive = Archive();
    // Use docx path from item
    final docxFile = File(item.pathTemplate);
    if (!docxFile.existsSync()) return null;

    final docxBytes = await docxFile.readAsBytes();
    archive.addFile(
      ArchiveFile(AppConst.settingDocFileName, docxBytes.length, docxBytes),
    );

    final configMap = item.toJson();
    final jsonString = jsonEncode(configMap);
    final jsonBytes = utf8.encode(jsonString);
    archive.addFile(
      ArchiveFile(AppConst.settingJsonFileName, jsonBytes.length, jsonBytes),
    );

    final zipEncoder = ZipEncoder();
    return zipEncoder.encode(archive);
  }

  String getSafeFileName(String templateName) {
    return templateName.replaceAll(RegExp(r'[^\w\s]+'), '_');
  }

  Future<void> saveExportedFile(List<int> bytes, String path) async {
    final exportFile = File(path);
    await exportFile.writeAsBytes(bytes);
  }

  Future<void> saveRawBytes(List<int> bytes, String path) async {
    final targetFile = File(path);
    if (!targetFile.existsSync()) {
      targetFile.createSync(recursive: true);
    }
    await targetFile.writeAsBytes(bytes);
  }

  String createCopyData({
    required Map<String, String?> fieldKeys,
    required Map<String, String?> singleField,
    required Set<String> imageKeys,
  }) {
    final fieldsToSave = Map<String, dynamic>.from(fieldKeys);
    fieldsToSave.removeWhere((key, value) => imageKeys.contains(key));

    final data = {'fields': fieldsToSave, 'singleLines': singleField};
    return jsonEncode(data);
  }

  Map<String, dynamic> parseCopyData(String content) {
    return jsonDecode(content);
  }

  Map<int, List<TemplateField>> groupFields(List<TemplateConfig> templates) {
    final rawData = <int, List<TemplateField>>{};

    if (templates.length == 1) {
      final template = templates.first;
      rawData[template.id] = template.fields;
      return rawData;
    }

    // Identify common keys across all templates
    final allFieldKeys = templates.expand((t) => t.fields.map((f) => f.key));
    final keyFrequency = allFieldKeys.fold(<String, int>{}, (map, key) {
      map[key] = (map[key] ?? 0) + 1;
      return map;
    });
    final commonKeys =
        keyFrequency.entries
            .where((e) => e.value == templates.length)
            .map((e) => e.key)
            .toSet();

    rawData[AppConst.commonUnknow] = [];

    for (var template in templates) {
      final specificFields = <TemplateField>[];

      for (var field in template.fields) {
        if (commonKeys.contains(field.key)) {
          // Add to common section only if not already added (based on key)
          final commonList = rawData[AppConst.commonUnknow]!;
          if (!commonList.any((e) => e.key == field.key)) {
            commonList.add(field);
          }
        } else {
          specificFields.add(field);
        }
      }
      rawData[template.id] = specificFields;
    }
    return rawData;
  }

  List<String> validateFields(
    List<TemplateConfig> templates,
    Map<String, String?> fieldKeys,
  ) {
    final requiredKeys = <String>{};
    for (var template in templates) {
      final templateRequired = template.fields
          .where((f) => f.required)
          .map((f) => f.key);
      requiredKeys.addAll(templateRequired);
    }
    return requiredKeys.where((key) => fieldKeys[key] == null).toList();
  }

  Map<String, (String, Size)> getImageReplacements({
    required Map<int, List<TemplateField>> composedUI,
    required Map<String, String> fieldKeys,
  }) {
    final allFields = composedUI.values.expand((element) => element);
    final imageFields = allFields.where((e) => e.type == FieldType.image);
    final result = <String, (String, Size)>{};

    for (var field in imageFields) {
      final key = field.key;
      final dimension = Dimensions.from(field.additionalInfo);
      final size = dimension?.toInches();
      final path = fieldKeys[key];

      if (dimension != null && path != null && size != null) {
        result[key] = (path, size);
      }
      fieldKeys.remove(key);
    }
    return result;
  }

  Future<void> executeExport({
    required List<TemplateConfig> templates,
    required String exportDirectory,
    required String baseFileName,
    required Map<String, String?> fieldKeys,
    required Map<String, String?> singleLines,
    required Map<int, List<TemplateField>> composedUI,
  }) async {
    // 1. Prepare data (Date formatting, defaults)
    final processedFieldKeys = _processFields(templates, fieldKeys);

    // 2. Extract image replacements
    final imageReplacements = getImageReplacements(
      composedUI: composedUI,
      fieldKeys: processedFieldKeys,
    );

    // 3. Run individual template exports
    for (var template in templates) {
      final fileOrigin = File(template.pathTemplate);
      if (!fileOrigin.existsSync()) continue;

      final originalBytes = await fileOrigin.readAsBytes();
      final rawBytes = await DocxUtils.composeModifiedDocxWithPlaceholders(
        originalBytes: originalBytes,
        replacements: processedFieldKeys,
        imageReplacements: imageReplacements,
        singleLines: singleLines,
      );

      final extension = template.pathTemplate.split(".").lastOrNull;
      final fileName = "${baseFileName}_${template.templateName}.$extension";
      final filePath = [exportDirectory, fileName].join(Platform.pathSeparator);

      await saveRawBytes(rawBytes, filePath);
    }
  }

  Map<String, String> _processFields(
    List<TemplateConfig> templates,
    Map<String, String?> fieldKeys,
  ) {
    final result = <String, String>{};
    final allFields = templates.expand((t) => t.fields);

    for (var field in allFields) {
      final value = fieldKeys[field.key];

      if (field.type == FieldType.datetime && value != null) {
        final format = field.additionalInfo;
        if (format != null && format.isNotEmpty) {
          result[field.key] = DateTimeUtils.format(value, format: format) ?? "";
          continue;
        }
      }

      result[field.key] = value ?? field.defaultValue ?? "";
    }
    return result;
  }
}
