import 'dart:io';

import 'package:data/data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late TemplateService templateService;

  setUp(() {
    templateService = TemplateService(
      templateRepository: _FakeTemplateRepository(),
    );
  });

  group('TemplateService - groupFields Logic Verification', () {
    test(
      '1. Should ensure uniqueness: 1 key only appears once across all groups',
      () {
        final templates = [
          TemplateConfig(
            templateName: 'T1',
            pathTemplate: '',
            version: '1',
            fields: [
              TemplateField(
                key: 'key1',
                label: 'Field 1',
                type: FieldType.text,
                required: true,
                section: 'Section A',
              ),
            ],
          ),
          TemplateConfig(
            templateName: 'T2',
            pathTemplate: '',
            version: '1',
            fields: [
              TemplateField(
                key: 'key1',
                label: 'Field 1 duplicate',
                type: FieldType.text,
                required: true,
                section: 'Section B',
              ),
            ],
          ),
        ];

        final result = templateService.groupFields(templates);

        final totalFields = result.values.expand((list) => list).length;
        expect(totalFields, 1, reason: 'Total unique keys should be 1');
      },
    );

    test(
      '2. Priority: Should prefer field with section over field without section',
      () {
        final templates = [
          TemplateConfig(
            templateName: 'T1',
            pathTemplate: '',
            version: '1',
            fields: [
              TemplateField(
                key: 'user_name',
                label: 'Name',
                type: FieldType.text,
                required: true,
                section: 'Profile',
              ),
            ],
          ),
          TemplateConfig(
            templateName: 'T2',
            pathTemplate: '',
            version: '1',
            fields: [
              TemplateField(
                key: 'user_name',
                label: 'Name',
                type: FieldType.text,
                required: true,
              ),
            ],
          ),
        ];

        final result = templateService.groupFields(templates);

        expect(result.containsKey('Profile'), isTrue);
        expect(result['Profile']!.any((f) => f.key == 'user_name'), isTrue);
        expect(result.containsKey(TemplateService.commonSectionKey), isFalse);
        expect(result.containsKey(TemplateService.unspecified), isFalse);
      },
    );

    test(
      '3. Common Group: Unsectioned fields appearing in ALL n templates',
      () {
        final templates = [
          TemplateConfig(
            templateName: 'T1',
            pathTemplate: '',
            version: '1',
            fields: [
              TemplateField(
                key: 'shared',
                label: 'Shared',
                type: FieldType.text,
                required: true,
              ),
            ],
          ),
          TemplateConfig(
            templateName: 'T2',
            pathTemplate: '',
            version: '1',
            fields: [
              TemplateField(
                key: 'shared',
                label: 'Shared',
                type: FieldType.text,
                required: true,
              ),
            ],
          ),
        ];

        final result = templateService.groupFields(templates);

        expect(result.containsKey(TemplateService.commonSectionKey), isTrue);
        expect(
          result[TemplateService.commonSectionKey]!.any(
            (f) => f.key == 'shared',
          ),
          isTrue,
        );
      },
    );

    test(
      '4. Unspecified Group: Unsectioned fields appearing in < n templates',
      () {
        final templates = [
          TemplateConfig(
            templateName: 'T1',
            pathTemplate: '',
            version: '1',
            fields: [
              TemplateField(
                key: 'partial',
                label: 'Partial',
                type: FieldType.text,
                required: true,
              ),
            ],
          ),
          TemplateConfig(
            templateName: 'T2',
            pathTemplate: '',
            version: '1',
            fields: [],
          ),
        ];

        final result = templateService.groupFields(templates);

        expect(result.containsKey(TemplateService.unspecified), isTrue);
        expect(
          result[TemplateService.unspecified]!.any((f) => f.key == 'partial'),
          isTrue,
        );
        expect(result.containsKey(TemplateService.commonSectionKey), isFalse);
      },
    );

    test('5. Complex Scenario: Combination of all rules', () {
      final templates = [
        TemplateConfig(
          templateName: 'T1',
          pathTemplate: '',
          version: '1',
          fields: [
            TemplateField(
              key: 'k1',
              label: 'L1',
              type: FieldType.text,
              required: true,
              section: 'S1',
            ),
            TemplateField(
              key: 'k2',
              label: 'L2',
              type: FieldType.text,
              required: true,
            ),
            TemplateField(
              key: 'k3',
              label: 'L3',
              type: FieldType.text,
              required: true,
            ),
          ],
        ),
        TemplateConfig(
          templateName: 'T2',
          pathTemplate: '',
          version: '1',
          fields: [
            TemplateField(
              key: 'k2',
              label: 'L2',
              type: FieldType.text,
              required: true,
            ),
            TemplateField(
              key: 'k4',
              label: 'L4',
              type: FieldType.text,
              required: true,
              section: 'S1',
            ),
          ],
        ),
      ];

      final result = templateService.groupFields(templates);

      final allFields = result.values.expand((list) => list).toList();
      expect(allFields.length, 4);

      expect(result['S1']!.length, 2);
      expect(result['S1']!.any((f) => f.key == 'k1'), isTrue);
      expect(result['S1']!.any((f) => f.key == 'k4'), isTrue);

      expect(
        result[TemplateService.commonSectionKey]!.any((f) => f.key == 'k2'),
        isTrue,
      );

      expect(
        result[TemplateService.unspecified]!.any((f) => f.key == 'k3'),
        isTrue,
      );
    });
  });

  group('TemplateService - template deletion', () {
    test(
      'soft deletes configuration and keeps physical template file',
      () async {
        final repository = _FakeTemplateRepository();
        final service = TemplateService(templateRepository: repository);
        final tempDir = await Directory.systemTemp.createTemp(
          'docu_fill_test_',
        );
        final templateFile = File('${tempDir.path}/template.docx');
        await templateFile.writeAsString('template');

        await service.deleteTemplate(
          TemplateConfig(
            id: 12,
            templateName: 'Template',
            pathTemplate: templateFile.path,
            version: '1',
            fields: [],
          ),
        );

        expect(repository.softDeletedIds, [12]);
        expect(await templateFile.exists(), isTrue);

        await tempDir.delete(recursive: true);
      },
    );
  });
}

class _FakeTemplateRepository implements TemplateRepository {
  final List<int> softDeletedIds = [];

  @override
  Future<void> softDeleteTemplate(int id) async {
    softDeletedIds.add(id);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
