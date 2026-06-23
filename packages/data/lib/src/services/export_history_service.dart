import 'package:data/src/export_history.dart';
import 'package:data/src/repositories/export_history/export_history_repository.dart';
import 'package:data/src/template_config.dart';
import 'package:data/src/template_export_result.dart';

class ExportHistoryService {
  final ExportHistoryRepository _repository;

  ExportHistoryService({required ExportHistoryRepository repository})
    : _repository = repository;

  Future<void> saveExportHistory({
    required List<TemplateConfig> templates,
    required String exportDirectory,
    required String baseFileName,
    required Map<String, String?> fieldValues,
    required Map<String, String?> singleLineValues,
    required TemplateExportResult result,
  }) async {
    final history = ExportHistory(
      baseFileName: baseFileName,
      exportDirectory: exportDirectory,
      status: _resolveStatus(result),
      templateIds: templates.map((template) => template.id).toList(),
      templateSnapshots: templates,
      fieldValues: Map<String, String?>.from(fieldValues),
      singleLineValues: Map<String, String?>.from(singleLineValues),
      outputFiles: result.outputFiles,
      errorMessage: result.errorMessage,
      documentCount: result.documentCount,
    );
    await _repository.saveHistory(history);
  }

  ExportHistoryStatus _resolveStatus(TemplateExportResult result) {
    if (!result.hasOutput) return ExportHistoryStatus.failed;
    if (result.hasIssues) return ExportHistoryStatus.partialSuccess;
    return ExportHistoryStatus.success;
  }
}
