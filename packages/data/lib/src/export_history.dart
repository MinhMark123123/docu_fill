import 'package:data/src/template_config.dart';
import 'package:json_annotation/json_annotation.dart';

part 'export_history.g.dart';

@JsonEnum()
enum ExportHistoryStatus {
  @JsonValue('success')
  success,
  @JsonValue('partialSuccess')
  partialSuccess,
  @JsonValue('failed')
  failed,
}

@JsonEnum()
enum CaseStudyStatus {
  @JsonValue('none')
  none,
  @JsonValue('good')
  good,
  @JsonValue('needsReview')
  needsReview,
  @JsonValue('failed')
  failed,
}

@JsonSerializable(explicitToJson: true)
class ExportHistory {
  int id;
  final DateTime createdAt;
  final String baseFileName;
  final String exportDirectory;
  final ExportHistoryStatus status;
  final List<int> templateIds;
  final List<TemplateConfig> templateSnapshots;
  final Map<String, String?> fieldValues;
  final Map<String, String?> singleLineValues;
  final List<String> outputFiles;
  final String? errorMessage;
  final int documentCount;
  final CaseStudyStatus caseStudyStatus;

  ExportHistory({
    this.id = 0,
    DateTime? createdAt,
    required this.baseFileName,
    required this.exportDirectory,
    required this.status,
    required this.templateIds,
    required this.templateSnapshots,
    required this.fieldValues,
    required this.singleLineValues,
    required this.outputFiles,
    this.errorMessage,
    required this.documentCount,
    this.caseStudyStatus = CaseStudyStatus.none,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ExportHistory.fromJson(Map<String, dynamic> json) =>
      _$ExportHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$ExportHistoryToJson(this);
}
