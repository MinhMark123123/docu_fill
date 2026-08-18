// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FieldValueEntry _$FieldValueEntryFromJson(Map<String, dynamic> json) =>
    FieldValueEntry(
      label: json['label'] as String,
      value: json['value'] as String?,
    );

Map<String, dynamic> _$FieldValueEntryToJson(FieldValueEntry instance) =>
    <String, dynamic>{'label': instance.label, 'value': instance.value};

ExportHistory _$ExportHistoryFromJson(
  Map<String, dynamic> json,
) => ExportHistory(
  id: (json['id'] as num?)?.toInt() ?? 0,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  baseFileName: json['baseFileName'] as String,
  exportDirectory: json['exportDirectory'] as String,
  status: $enumDecode(_$ExportHistoryStatusEnumMap, json['status']),
  templateIds:
      (json['templateIds'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
  templateSnapshots:
      (json['templateSnapshots'] as List<dynamic>)
          .map((e) => TemplateConfig.fromJson(e as Map<String, dynamic>))
          .toList(),
  fieldValues: (json['fieldValues'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, FieldValueEntry.fromJson(e as Map<String, dynamic>)),
  ),
  singleLineValues: (json['singleLineValues'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, FieldValueEntry.fromJson(e as Map<String, dynamic>)),
  ),
  outputFiles:
      (json['outputFiles'] as List<dynamic>).map((e) => e as String).toList(),
  errorMessage: json['errorMessage'] as String?,
  documentCount: (json['documentCount'] as num).toInt(),
  caseStudyStatus:
      $enumDecodeNullable(_$CaseStudyStatusEnumMap, json['caseStudyStatus']) ??
      CaseStudyStatus.none,
);

Map<String, dynamic> _$ExportHistoryToJson(
  ExportHistory instance,
) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt.toIso8601String(),
  'baseFileName': instance.baseFileName,
  'exportDirectory': instance.exportDirectory,
  'status': _$ExportHistoryStatusEnumMap[instance.status]!,
  'templateIds': instance.templateIds,
  'templateSnapshots':
      instance.templateSnapshots.map((e) => e.toJson()).toList(),
  'fieldValues': instance.fieldValues.map((k, e) => MapEntry(k, e.toJson())),
  'singleLineValues': instance.singleLineValues.map(
    (k, e) => MapEntry(k, e.toJson()),
  ),
  'outputFiles': instance.outputFiles,
  'errorMessage': instance.errorMessage,
  'documentCount': instance.documentCount,
  'caseStudyStatus': _$CaseStudyStatusEnumMap[instance.caseStudyStatus]!,
};

const _$ExportHistoryStatusEnumMap = {
  ExportHistoryStatus.success: 'success',
  ExportHistoryStatus.partialSuccess: 'partialSuccess',
  ExportHistoryStatus.failed: 'failed',
};

const _$CaseStudyStatusEnumMap = {
  CaseStudyStatus.none: 'none',
  CaseStudyStatus.good: 'good',
  CaseStudyStatus.needsReview: 'needsReview',
  CaseStudyStatus.failed: 'failed',
};
