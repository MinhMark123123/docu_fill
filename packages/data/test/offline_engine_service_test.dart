import 'dart:convert';
import 'dart:io';

import 'package:data/data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

class _FakeHistories implements ExportHistoryRepository {
  @override
  Future<List<ExportHistory>> getAllHistories() async => [
    _history(sources: []), // exported before source text was kept
    _history(
      sources: [
        SourceDocument(
          fileName: 'a.xlsx',
          sourceType: 'xlsx',
          text: 'Số | 4310',
          method: 'gemini_text',
          predictedValues: {},
        ),
      ],
    ),
  ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ExportHistory _history({required List<SourceDocument> sources}) =>
    ExportHistory(
      baseFileName: 'x',
      exportDirectory: '',
      status: ExportHistoryStatus.success,
      templateIds: [],
      templateSnapshots: [],
      fieldValues: {
        '%%So%%': const FieldValueEntry(label: 'Số', value: '4310'),
        '%%Empty%%': const FieldValueEntry(label: 'Trống'),
      },
      singleLineValues: {},
      outputFiles: [],
      documentCount: 1,
      sources: sources,
    );

/// Stand-in for docufill_engine: keeps a copy of the request next to itself
/// (last_request.json), prints progress, fails when the text is "fail".
const _fakeEngine = r'''
import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final output = args[args.indexOf('--output') + 1];
  stderr.writeln('PROGRESS {"stage": "apply_rules", "done": 1, "total": 2}');
  if (args.first == 'ocr') {
    File(output).writeAsStringSync(jsonEncode({'text': 'Số | 4312'}));
    return;
  }
  final requestFile = File(args[args.indexOf('--request') + 1]);
  requestFile.copySync(
    File.fromUri(Platform.script).parent.path + '/last_request.json',
  );
  final request = jsonDecode(requestFile.readAsStringSync());
  if (request['text'] == 'fail') {
    stderr.writeln('ERROR ValueError: bad request');
    exit(1);
  }
  File(output).writeAsStringSync(jsonEncode({
    'values': {
      '%%So%%': {
        'value': '4312',
        'source': args.contains('--llm') ? 'llm' : 'rule',
        'confidence': 0.95,
        'review': false,
      },
    },
  }));
}
''';

void main() {
  late Directory temp;
  late OfflineEngineService service;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('engine_test_');
    final script = File(p.join(temp.path, 'fake_engine.dart'));
    await script.writeAsString(_fakeEngine);
    final shared = Directory(
      p.join(temp.path, OfflineEngineService.sharedCasesFolder),
    );
    await shared.create();
    await File(p.join(shared.path, 'other_machine.json')).writeAsString('[]');
    await File(p.join(shared.path, 'notes.txt')).writeAsString('ignored');
    service = OfflineEngineService(
      _FakeHistories(),
      documentsDirectory: () async => temp,
      engineCommand: [_dart(), 'run', script.path],
    );
  });

  tearDown(() async => temp.delete(recursive: true));

  test('mapText sends past cases and shared files, parses values', () async {
    final progress = <EngineProgress>[];
    final values = await service.mapText(
      text: 'Số | 4312',
      fields: {'%%So%%': null},
      useLlm: true,
      onProgress: progress.add,
    );

    expect(values['%%So%%']!.value, '4312');
    expect(values['%%So%%']!.source, 'llm');
    expect(progress.single.stage, 'apply_rules');
    expect(progress.single.total, 2);
  });

  test('request holds only cases with source text and filled values', () async {
    await service.mapText(
      text: 'Số | 4312',
      fields: {'%%So%%': null},
      useLlm: false,
    );
    final request = jsonDecode(
      await File(p.join(temp.path, 'last_request.json')).readAsString(),
    );
    expect(request['fields'], {'%%So%%': ''});
    expect(request['cases'], [
      {
        'text': 'Số | 4310',
        'values': {'%%So%%': '4310'},
      },
    ]);
    expect(
      (request['case_files'] as List).map((f) => p.basename(f as String)),
      ['other_machine.json'],
    );
  });

  test('ocrPdf returns the engine text', () async {
    expect(await service.ocrPdf(File('scan.pdf')), 'Số | 4312');
  });

  test('engine errors surface with their message', () async {
    expect(
      service.mapText(text: 'fail', fields: {}, useLlm: false),
      throwsA(
        isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('ValueError: bad request'),
        ),
      ),
    );
  });

  test('temporary request files are deleted', () async {
    final before = _engineTempDirs();
    await service.mapText(text: 'Số | 4312', fields: {}, useLlm: false);
    expect(_engineTempDirs(), before);
  });
}

/// The Dart SDK executable (flutter test runs in flutter_tester, not dart).
String _dart() {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot == null) return 'dart';
  return p.join(flutterRoot, 'bin', 'cache', 'dart-sdk', 'bin', 'dart.exe');
}

Set<String> _engineTempDirs() =>
    Directory.systemTemp
        .listSync()
        .where((e) => p.basename(e.path).startsWith('docu_fill_engine_'))
        .map((e) => e.path)
        .toSet();
