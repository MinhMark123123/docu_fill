import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:archive/archive.dart';
import 'package:core/const/const.dart';
import 'package:core/utils/utils.dart';
import 'package:data/data.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

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
    // Get the actual extension of the template file
    final templateFile = File(item.pathTemplate);
    if (!templateFile.existsSync()) return null;

    final extension = p.extension(item.pathTemplate);
    final docBytes = await templateFile.readAsBytes();

    // Add the template file with its correct extension
    archive.addFile(
      ArchiveFile(
        "${AppConst.settingDocFileName}$extension",
        docBytes.length,
        docBytes,
      ),
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
    if (!targetFile.parent.existsSync()) {
      targetFile.parent.createSync(recursive: true);
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

  /// Sentinel key used to mark fields that are shared across all templates.
  static const String commonSectionKey = '__common__';

  /// Groups template fields by their [TemplateField.section] value.
  Map<String?, List<TemplateField>> groupFields(
    List<TemplateConfig> templates,
  ) {
    if (templates.isEmpty) return {};

    final groupedData = <String?, List<TemplateField>>{};

    // 1. Identify common fields (only if multiple templates)
    Set<String> commonKeys = {};
    if (templates.length > 1) {
      final allFieldKeys = templates.expand((t) => t.fields.map((f) => f.key));
      final keyFrequency = allFieldKeys.fold(<String, int>{}, (map, key) {
        map[key] = (map[key] ?? 0) + 1;
        return map;
      });
      commonKeys =
          keyFrequency.entries
              .where((e) => e.value == templates.length)
              .map((e) => e.key)
              .toSet();

      if (commonKeys.isNotEmpty) {
        groupedData[commonSectionKey] = [];
      }
    }

    // 2. Identify unique fields across all templates with priority rule
    // Priority: Prefer field with a non-empty section over one without.
    final Map<String, TemplateField> uniqueFieldsMap = {};
    for (var template in templates) {
      for (var field in template.fields) {
        final existing = uniqueFieldsMap[field.key];
        if (existing == null) {
          uniqueFieldsMap[field.key] = field;
        } else {
          final existingHasSection =
              existing.section?.trim().isNotEmpty == true;
          final currentHasSection = field.section?.trim().isNotEmpty == true;
          // If current field has a section and existing one doesn't, use current.
          if (!existingHasSection && currentHasSection) {
            uniqueFieldsMap[field.key] = field;
          }
        }
      }
    }

    // 3. Group the unique/prioritized fields
    for (var field in uniqueFieldsMap.values) {
      if (commonKeys.contains(field.key)) {
        groupedData[commonSectionKey]!.add(field);
        continue;
      }

      // field.section is null when no section was configured
      final sectionKey =
          field.section?.trim().isEmpty == true ? null : field.section;
      groupedData.putIfAbsent(sectionKey, () => []).add(field);
    }

    return groupedData;
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
    required Map<String, List<TemplateField>> composedUI,
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
    required Map<String, List<TemplateField>> composedUI,
  }) async {
    // 1. Prepare data (Date formatting, defaults)
    final processedFieldKeys = _processFields(templates, fieldKeys);

    // 2. Run individual template exports
    for (var template in templates) {
      final fileOrigin = File(template.pathTemplate);
      if (!fileOrigin.existsSync()) continue;

      final extension = template.pathTemplate.split('.').last.toLowerCase();
      final originalBytes = await fileOrigin.readAsBytes();
      Uint8List rawBytes;

      if (extension == 'docx') {
        // --- ONLY DOCX: Handle Images ---
        final Map<String, String> fieldKeysForImages = Map.from(
          processedFieldKeys,
        );
        final imageReplacements = getImageReplacements(
          composedUI: composedUI,
          fieldKeys: fieldKeysForImages,
        );

        rawBytes = await DocxUtils.composeModifiedDocxWithPlaceholders(
          originalBytes: originalBytes,
          replacements: processedFieldKeys,
          imageReplacements: imageReplacements,
          singleLines: singleLines,
        );
      } else if (extension == 'xlsx' || extension == 'xls') {
        // --- EXCEL: Handle Text replacements only ---
        rawBytes = await ExcelUtils.composeModifiedExcel(
          originalBytes: originalBytes,
          replacements: processedFieldKeys,
        );
      } else {
        // Skip unsupported formats
        continue;
      }

      final fileName = "${baseFileName}_${template.templateName}.$extension";
      final filePath = p.join(exportDirectory, fileName);

      await saveRawBytes(rawBytes, filePath);
    }
  }

  /// Exports the input summary as a plain text file.
  Future<void> exportSummaryText({
    required String exportDirectory,
    required String baseFileName,
    required Map<String, List<TemplateField>> composedUI,
    required Map<String, String?> fieldKeys,
    required Map<String, String?> singleLines,
  }) async {
    final buffer = StringBuffer();
    buffer.writeln("DOCUFILL - INPUT SUMMARY");
    buffer.writeln("Generated on: ${DateTime.now()}");
    buffer.writeln("=" * 30);

    composedUI.forEach((section, fields) {
      buffer.writeln("\n[$section]");
      for (var field in fields) {
        final value = fieldKeys[field.key] ?? singleLines[field.key] ?? "-";
        buffer.writeln("${field.label}: $value");
      }
    });

    final fileName = "${baseFileName}_summary.txt";
    final filePath = p.join(exportDirectory, fileName);
    final file = File(filePath);
    await file.writeAsString(buffer.toString());
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
