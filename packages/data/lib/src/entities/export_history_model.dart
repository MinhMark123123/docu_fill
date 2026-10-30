import 'dart:convert';

import 'package:data/src/export_history.dart';
import 'package:data/src/template_config.dart';
import 'package:isar_community/isar.dart';

part 'export_history_model.g.dart';

@collection
class ExportHistoryModel {
  Id id = Isar.autoIncrement;

  DateTime? createdAt;
  late String baseFileName;
  late String exportDirectory;
  late String status;
  late List<int> templateIds;
  late String templateSnapshotsJson;
  late String fieldValuesJson;
  late String singleLineValuesJson;
  late List<String> outputFiles;
  String? errorMessage;
  late int documentCount;
  late String caseStudyStatus;
  String? sourcesJson;

  ExportHistoryModel({
    this.id = Isar.autoIncrement,
    this.createdAt,
    this.baseFileName = '',
    this.exportDirectory = '',
    this.status = 'success',
    this.templateIds = const [],
    this.templateSnapshotsJson = '[]',
    this.fieldValuesJson = '{}',
    this.singleLineValuesJson = '{}',
    this.outputFiles = const [],
    this.errorMessage,
    this.documentCount = 0,
    this.caseStudyStatus = 'none',
    this.sourcesJson,
  });

  factory ExportHistoryModel.fromDomain(ExportHistory history) {
    return ExportHistoryModel(
      id: history.id == 0 ? Isar.autoIncrement : history.id,
      createdAt: history.createdAt,
      baseFileName: history.baseFileName,
      exportDirectory: history.exportDirectory,
      status: history.status.name,
      templateIds: history.templateIds,
      templateSnapshotsJson: jsonEncode(
        history.templateSnapshots.map((template) => template.toJson()).toList(),
      ),
      fieldValuesJson: jsonEncode(
        history.fieldValues.map((key, value) => MapEntry(key, value.toJson())),
      ),
      singleLineValuesJson: jsonEncode(
        history.singleLineValues.map(
          (key, value) => MapEntry(key, value.toJson()),
        ),
      ),
      outputFiles: history.outputFiles,
      errorMessage: history.errorMessage,
      documentCount: history.documentCount,
      caseStudyStatus: history.caseStudyStatus.name,
      sourcesJson: jsonEncode(
        history.sources.map((source) => source.toJson()).toList(),
      ),
    );
  }

  ExportHistory toDomain() {
    return ExportHistory(
      id: id,
      createdAt: createdAt ?? DateTime.now(),
      baseFileName: baseFileName,
      exportDirectory: exportDirectory,
      status: _statusFromName(status),
      templateIds: templateIds,
      templateSnapshots: _templateSnapshots(),
      fieldValues: _fieldValueMap(fieldValuesJson),
      singleLineValues: _fieldValueMap(singleLineValuesJson),
      outputFiles: outputFiles,
      errorMessage: errorMessage,
      documentCount: documentCount,
      caseStudyStatus: _caseStudyStatusFromName(caseStudyStatus),
      sources: _sources(),
    );
  }

  // Records saved before sources were tracked have no sourcesJson.
  List<SourceDocument> _sources() {
    final content = sourcesJson;
    if (content == null || content.isEmpty) return [];
    final decoded = jsonDecode(content);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(SourceDocument.fromJson)
        .toList();
  }

  List<TemplateConfig> _templateSnapshots() {
    final decoded = jsonDecode(templateSnapshotsJson);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(TemplateConfig.fromJson)
        .toList();
  }

  Map<String, FieldValueEntry> _fieldValueMap(String content) {
    final decoded = jsonDecode(content);
    if (decoded is! Map) return {};
    return decoded.map(
      (key, value) => MapEntry(
        key.toString(),
        _fieldValueEntry(key.toString(), value),
      ),
    );
  }

  // Old records stored plain string values instead of {label, value} objects.
  FieldValueEntry _fieldValueEntry(String key, dynamic value) {
    if (value is Map) {
      return FieldValueEntry.fromJson(Map<String, dynamic>.from(value));
    }
    return FieldValueEntry(label: key, value: value?.toString());
  }

  ExportHistoryStatus _statusFromName(String value) {
    return ExportHistoryStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => ExportHistoryStatus.failed,
    );
  }

  CaseStudyStatus _caseStudyStatusFromName(String value) {
    return CaseStudyStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => CaseStudyStatus.none,
    );
  }
}
