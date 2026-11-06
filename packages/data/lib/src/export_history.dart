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
class FieldValueEntry {
  final String label;
  final String? value;

  const FieldValueEntry({required this.label, this.value});

  factory FieldValueEntry.fromJson(Map<String, dynamic> json) =>
      _$FieldValueEntryFromJson(json);

  Map<String, dynamic> toJson() => _$FieldValueEntryToJson(this);
}

/// A source file imported while filling a case, kept so the field mapping can
/// later learn from the values the user finally exported.
@JsonSerializable(explicitToJson: true)
class SourceDocument {
  final String fileName;

  /// File extension: docx, xlsx, xls, pdf.
  final String sourceType;

  /// Normalized extracted text (rows of " | "-separated cells). Empty when
  /// the file was sent to the mapper as-is (e.g. scanned PDF).
  final String text;

  /// How the values were produced, e.g. "gemini_text" or "gemini_file".
  final String method;

  /// Values the mapper proposed for this file, before user edits.
  final Map<String, String> predictedValues;

  /// What produced each predicted value: "form", "certificate", "rule" or "llm". Compared with the
  /// exported values, this shows which mapper to trust for each field.
  @JsonKey(defaultValue: <String, String>{})
  final Map<String, String> predictedSources;
  final DateTime importedAt;

  SourceDocument({
    required this.fileName,
    required this.sourceType,
    required this.text,
    required this.method,
    required this.predictedValues,
    this.predictedSources = const {},
    DateTime? importedAt,
  }) : importedAt = importedAt ?? DateTime.now();

  factory SourceDocument.fromJson(Map<String, dynamic> json) =>
      _$SourceDocumentFromJson(json);

  Map<String, dynamic> toJson() => _$SourceDocumentToJson(this);
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
  final Map<String, FieldValueEntry> fieldValues;
  final Map<String, FieldValueEntry> singleLineValues;
  final List<String> outputFiles;
  final String? errorMessage;
  final int documentCount;
  final CaseStudyStatus caseStudyStatus;
  @JsonKey(defaultValue: <SourceDocument>[])
  final List<SourceDocument> sources;

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
    this.sources = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  factory ExportHistory.fromJson(Map<String, dynamic> json) =>
      _$ExportHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$ExportHistoryToJson(this);

  /// The same export with the user's choice of whether the offline engine
  /// learns from it.
  ExportHistory withCaseStudyStatus(CaseStudyStatus value) => ExportHistory(
    id: id,
    createdAt: createdAt,
    baseFileName: baseFileName,
    exportDirectory: exportDirectory,
    status: status,
    templateIds: templateIds,
    templateSnapshots: templateSnapshots,
    fieldValues: fieldValues,
    singleLineValues: singleLineValues,
    outputFiles: outputFiles,
    errorMessage: errorMessage,
    documentCount: documentCount,
    caseStudyStatus: value,
    sources: sources,
  );

  /// Values the mapper proposed when the source files were imported.
  Map<String, String> get predictedValues => {
    for (final source in sources) ...source.predictedValues,
  };

  /// Exported almost as proposed, so probably not checked. Mirrors
  /// tools/mapper/reviewed.py, which makes the actual decision in the engine.
  bool get looksUnreviewed {
    final predicted = predictedValues;
    if (predicted.length < 20) return false;
    String words(String? v) => (v ?? '').trim().split(RegExp(r'\s+')).join(' ');
    final exported = {
      for (final e in [...fieldValues.entries, ...singleLineValues.entries])
        e.key: e.value.value,
    };
    final changed =
        predicted.entries
            .where((e) => words(exported[e.key]) != words(e.value))
            .length;
    return changed / predicted.length < 0.03;
  }

  /// Whether the offline engine learns from this export.
  bool get usedForLearning => switch (caseStudyStatus) {
    CaseStudyStatus.good => true,
    CaseStudyStatus.failed => false,
    _ => !looksUnreviewed,
  };
}
