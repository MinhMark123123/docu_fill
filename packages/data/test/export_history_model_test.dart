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
      fieldValues: {'customer_name': 'Minh'},
      singleLineValues: {'note': 'Approved'},
      outputFiles: ['/tmp/exports/contract_Template.docx'],
      documentCount: 1,
    );

    final model = ExportHistoryModel.fromDomain(history);
    final restored = model.toDomain();

    expect(restored.baseFileName, history.baseFileName);
    expect(restored.status, ExportHistoryStatus.success);
    expect(restored.templateSnapshots.first.templateName, 'Template');
    expect(restored.fieldValues['customer_name'], 'Minh');
    expect(restored.singleLineValues['note'], 'Approved');
    expect(restored.outputFiles, history.outputFiles);
  });
}
