import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:data/data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

class _FakeTemplates implements TemplateRepository {
  @override
  Future<List<TemplateConfig>> getAllTemplates() async => [
    TemplateConfig(
      id: 3,
      templateName: 'BCDG',
      pathTemplate: 'bcdg.docx',
      version: '1',
      fields: [],
    ),
  ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHistories implements ExportHistoryLocalDataSource {
  @override
  Future<List<ExportHistoryModel>> getAllHistories() async => [
    ExportHistoryModel(id: 1, baseFileName: 'old'), // saved before createdAt fix
    ExportHistoryModel.fromDomain(
      ExportHistory(
        id: 2,
        createdAt: DateTime(2026, 10, 30),
        baseFileName: '4310',
        exportDirectory: '',
        status: ExportHistoryStatus.success,
        templateIds: [3],
        templateSnapshots: [],
        fieldValues: {},
        singleLineValues: {},
        outputFiles: [],
        documentCount: 1,
        sources: [
          SourceDocument(
            fileName: 'a.xlsx',
            sourceType: 'xlsx',
            text: 'Số thửa | 195',
            method: 'gemini_text',
            predictedValues: {'%%SoThuaDat%%': '195'},
          ),
        ],
      ),
    ),
  ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSettings implements SettingsRepository {
  @override
  Future<AppSettingsModel?> getSettings() async =>
      AppSettingsModel()..geminiApiKey = 'secret-key';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late Directory temp;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('data_export_test_');
  });

  tearDown(() async {
    await temp.delete(recursive: true);
  });

  test('exportAll packs data without the API key', () async {
    final documents = await Directory(p.join(temp.path, 'docs')).create();
    final logs = await Directory(p.join(documents.path, 'api_logs')).create();
    await File(p.join(logs.path, 'log_1.txt')).writeAsString('prompt');

    final service = DataExportService(
      templateRepository: _FakeTemplates(),
      historyDataSource: _FakeHistories(),
      settingsRepository: _FakeSettings(),
      documentsDirectory: () async => documents,
    );
    final zipPath = await service.exportAll(temp.path);

    final archive = ZipDecoder().decodeBytes(File(zipPath).readAsBytesSync());
    Object? json(String name) =>
        jsonDecode(utf8.decode(archive.findFile(name)!.content as List<int>));

    expect(archive.findFile('api_logs/log_1.txt'), isNotNull);

    final histories = json('export_histories.json') as List;
    expect(histories.first['createdAt'], isNull);
    expect(histories.last['createdAt'], startsWith('2026-10-30'));
    expect(histories.last['sources'].first['text'], 'Số thửa | 195');

    final settings = json('settings.json') as Map;
    expect(settings['geminiApiKey'], '<redacted>');
    expect(utf8.decode(File(zipPath).readAsBytesSync(), allowMalformed: true),
        isNot(contains('secret-key')));

    final manifest = json('manifest.json') as Map;
    expect(manifest['format'], DataExportService.formatVersion);
    expect(manifest['histories'], 2);
    expect(manifest['historiesWithSources'], 1);
    expect(manifest['api_logs'], 1);
  });
}
