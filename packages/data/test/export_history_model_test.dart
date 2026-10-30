import 'package:data/data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ExportHistoryModel preserves snapshot data', () {
    final history = ExportHistory(
      baseFileName: 'contract',
      exportDirectory: '/tmp/exports',
      status: ExportHistoryStatus.success,
      templateIds: [1],
      templateSnapshots: [
        TemplateConfig(
          id: 1,
          templateName: 'Template',
          pathTemplate: '/tmp/template.docx',
          version: '1',
          fields: [
            TemplateField(
              key: 'customer_name',
              label: 'Customer name',
              type: FieldType.text,
              required: true,
            ),
          ],
        ),
      ],
      fieldValues: {
        'customer_name': FieldValueEntry(label: 'Customer name', value: 'Minh'),
      },
      singleLineValues: {
        'note': FieldValueEntry(label: 'Note', value: 'Approved'),
      },
      outputFiles: ['/tmp/exports/contract_Template.docx'],
      documentCount: 1,
    );

    final model = ExportHistoryModel.fromDomain(history);
    final restored = model.toDomain();

    expect(restored.baseFileName, history.baseFileName);
    expect(restored.status, ExportHistoryStatus.success);
    expect(restored.templateSnapshots.first.templateName, 'Template');
    expect(restored.fieldValues['customer_name']?.value, 'Minh');
    expect(restored.fieldValues['customer_name']?.label, 'Customer name');
    expect(restored.singleLineValues['note']?.value, 'Approved');
    expect(restored.singleLineValues['note']?.label, 'Note');
    expect(restored.outputFiles, history.outputFiles);
  });

  test('ExportHistoryModel keeps createdAt and source documents', () {
    final createdAt = DateTime(2026, 10, 30, 9, 15);
    final history = ExportHistory(
      createdAt: createdAt,
      baseFileName: '4310',
      exportDirectory: '/tmp/exports',
      status: ExportHistoryStatus.success,
      templateIds: [1],
      templateSnapshots: [],
      fieldValues: {},
      singleLineValues: {},
      outputFiles: [],
      documentCount: 1,
      sources: [
        SourceDocument(
          fileName: 'bang_tinh.xlsx',
          sourceType: 'xlsx',
          text: '--- Sheet: BC ---\nToạ độ tài sản: |  | 10.93, 108.11',
          method: 'gemini_text',
          predictedValues: {'%%ToaDoGoogleMap%%': '10.93, 108.11'},
        ),
      ],
    );

    final restored = ExportHistoryModel.fromDomain(history).toDomain();

    expect(restored.createdAt, createdAt);
    expect(restored.sources, hasLength(1));
    expect(restored.sources.first.fileName, 'bang_tinh.xlsx');
    expect(restored.sources.first.text, contains('Toạ độ tài sản'));
    expect(
      restored.sources.first.predictedValues['%%ToaDoGoogleMap%%'],
      '10.93, 108.11',
    );
  });

  test('ExportHistoryModel without sourcesJson restores no sources', () {
    final model = ExportHistoryModel()..sourcesJson = null;
    expect(model.toDomain().sources, isEmpty);
  });
}
