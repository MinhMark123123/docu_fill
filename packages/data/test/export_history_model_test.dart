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
}
