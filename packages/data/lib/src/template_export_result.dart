import 'package:data/src/template_config.dart';

class TemplateExportResult {
  final List<String> outputFiles;
  final List<TemplateExportIssue> issues;
  final int requestedCount;

  const TemplateExportResult({
    required this.outputFiles,
    required this.issues,
    required this.requestedCount,
  });

  int get documentCount => outputFiles.length;

  bool get hasIssues => issues.isNotEmpty;

  bool get hasOutput => outputFiles.isNotEmpty;

  String? get errorMessage {
    if (issues.isEmpty) return null;
    return issues.map((issue) => issue.message).join('\n');
  }
}

class TemplateExportIssue {
  final int templateId;
  final String templateName;
  final String message;

  const TemplateExportIssue({
    required this.templateId,
    required this.templateName,
    required this.message,
  });

  factory TemplateExportIssue.fromTemplate(
    TemplateConfig template,
    String message,
  ) {
    return TemplateExportIssue(
      templateId: template.id,
      templateName: template.templateName,
      message: '${template.templateName}: $message',
    );
  }
}
