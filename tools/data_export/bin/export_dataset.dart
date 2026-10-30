// Converts zips produced by collect_docu_fill_data.ps1 into JSON datasets.
//
// Usage:
//   dart run bin/export_dataset.dart <zip-or-folder>... [--out <dir>] [--isar-lib <libisar.dll>]
//
// Only entity files are imported (not package:data/data.dart) so the tool runs
// on the plain Dart VM without dart:ui.
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:data/src/entities/app_settings_model.dart';
import 'package:data/src/entities/export_history_model.dart';
import 'package:data/src/entities/template_config_model.dart';
import 'package:isar_community/isar.dart';
import 'package:path/path.dart' as p;

const _dbName = 'docu_fill';
const _encoder = JsonEncoder.withIndent('  ');

Future<void> main(List<String> args) async {
  final inputs = <String>[];
  var outDir = 'out';
  String? isarLib;
  for (var i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--out':
        outDir = args[++i];
      case '--isar-lib':
        isarLib = args[++i];
      default:
        inputs.add(args[i]);
    }
  }
  if (inputs.isEmpty) {
    stderr.writeln(
      'Usage: dart run bin/export_dataset.dart <zip-or-folder>... '
      '[--out <dir>] [--isar-lib <libisar.dll>]',
    );
    exit(64);
  }

  final workDir = await Directory.systemTemp.createTemp('docu_fill_export_');
  try {
    final sources = <_Source>[];
    for (final input in inputs) {
      sources.add(await _prepareSource(input, workDir));
    }

    isarLib ??=
        sources
            .map((s) => p.join(s.dir, 'libisar.dll'))
            .where((path) => File(path).existsSync())
            .firstOrNull;
    if (isarLib == null) {
      stderr.writeln(
        'libisar.dll not found in inputs; pass --isar-lib '
        '"C:\\Program Files\\DocuFill\\libisar.dll".',
      );
      exit(1);
    }
    await Isar.initializeIsarCore(
      libraries: {Abi.current(): File(isarLib).absolute.path},
    );

    final allPairs = <Map<String, dynamic>>[];
    for (final source in sources) {
      final pairs = await _exportSource(source, outDir);
      allPairs.addAll(pairs);
    }
    await _writeJsonl(File(p.join(outDir, 'dataset_all.jsonl')), allPairs);
    stdout.writeln(
      'Done: ${sources.length} machine(s), ${allPairs.length} pair(s) -> $outDir',
    );
  } finally {
    // libisar keeps the database file mapped until the process exits.
    try {
      await workDir.delete(recursive: true);
    } on FileSystemException {
      stderr.writeln('Note: temp folder not removed: ${workDir.path}');
    }
  }
}

class _Source {
  _Source(this.machine, this.dir);

  final String machine;
  final String dir;
}

Future<_Source> _prepareSource(String input, Directory workDir) async {
  var dir = input;
  if (FileSystemEntity.isFileSync(input) && input.toLowerCase().endsWith('.zip')) {
    dir = p.join(workDir.path, p.basenameWithoutExtension(input));
    await extractFileToDisk(input, dir);
  }
  if (!File(p.join(dir, '$_dbName.isar')).existsSync()) {
    throw ArgumentError('$input does not contain $_dbName.isar');
  }

  var machine = p.basenameWithoutExtension(input);
  final manifest = File(p.join(dir, 'manifest.json'));
  if (manifest.existsSync()) {
    final json = jsonDecode(await manifest.readAsString());
    machine = json['machine'] as String? ?? machine;
  }
  return _Source(machine, dir);
}

Future<List<Map<String, dynamic>>> _exportSource(
  _Source source,
  String outRoot,
) async {
  final outDir = Directory(p.join(outRoot, source.machine));
  await outDir.create(recursive: true);

  // Open a copy so the collected database file stays untouched.
  final dbDir = await Directory(p.join(source.dir, '_db')).create();
  await File(
    p.join(source.dir, '$_dbName.isar'),
  ).copy(p.join(dbDir.path, '$_dbName.isar'));
  final isar = await Isar.open(
    [TemplateConfigModelSchema, AppSettingsModelSchema, ExportHistoryModelSchema],
    directory: dbDir.path,
    name: _dbName,
    inspector: false,
  );

  try {
    final templates = await isar.templateConfigModels.where().findAll();
    final templatesJson = [
      for (final t in templates) {'id': t.id, ...t.toDomain().toJson()},
    ];
    await _writeJson(File(p.join(outDir.path, 'templates.json')), templatesJson);

    final settings = await isar.appSettingsModels.where().findAll();
    await _writeJson(File(p.join(outDir.path, 'settings.json')), [
      for (final s in settings)
        {
          'id': s.id,
          'geminiApiKey': (s.geminiApiKey?.isNotEmpty ?? false) ? '<redacted>' : null,
          'geminiModel': s.geminiModel,
          'geminiStudyData': s.geminiStudyData,
          'geminiSampleResult': s.geminiSampleResult,
          'enableApiLogging': s.enableApiLogging,
          'languageCode': s.languageCode,
          'countryCode': s.countryCode,
        },
    ]);

    final histories = await isar.exportHistoryModels.where().findAll();
    // toDomain() substitutes DateTime.now() for a missing createdAt; keep the
    // stored value (null for records saved before createdAt was persisted).
    final historiesJson = [
      for (final h in histories)
        {
          ...h.toDomain().toJson(),
          'id': h.id,
          'createdAt': h.createdAt?.toIso8601String(),
        },
    ];
    await _writeJson(
      File(p.join(outDir.path, 'export_histories.json')),
      historiesJson,
    );

    final logs = await _parseLogs(Directory(p.join(source.dir, 'api_logs')));
    await _writeJsonl(File(p.join(outDir.path, 'api_logs.jsonl')), logs);

    final pairs = _pairLogsWithHistories(source.machine, logs, historiesJson);
    await _writeJsonl(File(p.join(outDir.path, 'dataset.jsonl')), pairs);

    stdout.writeln(
      '[${source.machine}] templates=${templates.length} '
      'histories=${histories.length} logs=${logs.length} pairs=${pairs.length}',
    );
    return pairs;
  } finally {
    await isar.close();
  }
}

final _timestampRe = RegExp(r'TIMESTAMP:\s*(.+)');
final _keyRe = RegExp(r'^- Key: "(.*?)"\s*(?:\(Description: (.*)\))?\s*$');

/// Parses log files written by GeminiService._logToFile.
Future<List<Map<String, dynamic>>> _parseLogs(Directory dir) async {
  if (!dir.existsSync()) return [];
  final files =
      dir.listSync().whereType<File>().where((f) => f.path.endsWith('.txt')).toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  final logs = <Map<String, dynamic>>[];
  for (final file in files) {
    final content = (await file.readAsString()).replaceAll('\r\n', '\n');
    final promptStart = content.indexOf('--- PROMPT ---');
    final responseStart = content.lastIndexOf('--- RESPONSE ---');
    if (promptStart == -1 || responseStart == -1) continue;

    final header = content.substring(0, promptStart);
    final prompt = content.substring(promptStart + 14, responseStart).trim();
    var response = content.substring(responseStart + 16);
    final footer = response.lastIndexOf('----------------------');
    if (footer != -1) response = response.substring(0, footer);
    response = response.trim();

    final errorMatch = RegExp(r'ERROR:\s*(.+)').firstMatch(header);
    final isFile = prompt.startsWith('FILE_UPLOAD_PROMPT:');
    final fields = <Map<String, String?>>[];
    for (final line in prompt.split('\n')) {
      final m = _keyRe.firstMatch(line.trim());
      if (m != null) fields.add({'key': m.group(1), 'description': m.group(2)});
    }

    logs.add({
      'logFile': p.basename(file.path),
      'timestamp': _timestampRe.firstMatch(header)?.group(1)?.trim(),
      'status': errorMatch != null || response == 'N/A' ? 'error' : 'success',
      'error': errorMatch?.group(1)?.trim(),
      // file = PDF/image sent directly to Gemini, text = Word/Excel raw text.
      'mode': isFile ? 'file' : 'text',
      'fileName':
          isFile ? prompt.split('\n').first.substring(19).trim() : null,
      'fields': fields,
      'rawText': isFile ? null : _between(prompt, 'EXTRACTED TEXT:\n', '\nJSON OUTPUT:'),
      'responseRaw': response,
      'response': _extractJson(response),
    });
  }
  return logs;
}

String? _between(String text, String start, String end) {
  final s = text.lastIndexOf(start);
  if (s == -1) return null;
  final e = text.lastIndexOf(end);
  return text.substring(s + start.length, e > s ? e : text.length).trim();
}

Map<String, dynamic>? _extractJson(String text) {
  final start = text.indexOf('{');
  final end = text.lastIndexOf('}');
  if (start == -1 || end <= start) return null;
  try {
    return Map<String, dynamic>.from(jsonDecode(text.substring(start, end + 1)));
  } catch (_) {
    return null;
  }
}

const _minMatchScore = 0.5;
const _minMatchedValues = 3;

/// Heuristic pairing: each Gemini log is attached to the export whose final
/// values agree most with the Gemini output. Timestamps can't be used because
/// older export records have no createdAt. The exported values are what the
/// user confirmed, so they serve as labels.
List<Map<String, dynamic>> _pairLogsWithHistories(
  String machine,
  List<Map<String, dynamic>> logs,
  List<Map<String, dynamic>> histories,
) {
  final valuesById = <int, Map<String, String?>>{
    for (final history in histories)
      history['id'] as int: {
        for (final entry in (history['fieldValues'] as Map).entries)
          entry.key as String: (entry.value as Map)['value'] as String?,
      },
  };

  final sourcesById = <int, List<Map<String, dynamic>>>{};
  for (final log in logs) {
    final output = log['response'] as Map<String, dynamic>?;
    if (log['status'] != 'success' || output == null) continue;

    int? bestId;
    var bestScore = 0.0;
    var bestMatched = 0;
    valuesById.forEach((id, values) {
      var filled = 0;
      var matched = 0;
      output.forEach((key, value) {
        final predicted = _normalize(value?.toString());
        if (predicted.isEmpty || !values.containsKey(key)) return;
        filled++;
        if (predicted == _normalize(values[key])) matched++;
      });
      final score = filled == 0 ? 0.0 : matched / filled;
      if (matched >= _minMatchedValues && score > bestScore) {
        bestId = id;
        bestScore = score;
        bestMatched = matched;
      }
    });
    if (bestId == null || bestScore < _minMatchScore) continue;

    sourcesById.putIfAbsent(bestId!, () => []).add({
      'logFile': log['logFile'],
      'timestamp': log['timestamp'],
      'mode': log['mode'],
      'fileName': log['fileName'],
      'rawText': log['rawText'],
      'geminiOutput': output,
      'matchScore': double.parse(bestScore.toStringAsFixed(3)),
      'matchedValues': bestMatched,
    });
  }

  final pairs = <Map<String, dynamic>>[];
  for (final history in histories) {
    final sources = sourcesById[history['id']];
    if (sources == null) continue;
    final values = valuesById[history['id']]!;

    final descriptions = <String, String?>{
      for (final template in history['templateSnapshots'] as List)
        for (final field in (template as Map)['fields'] as List)
          (field as Map)['key'] as String: field['description'] as String?,
    };
    pairs.add({
      'machine': machine,
      'historyId': history['id'],
      'createdAt': history['createdAt'],
      'caseStudyStatus': history['caseStudyStatus'],
      'templates': [
        for (final t in history['templateSnapshots'] as List) t['template_name'],
      ],
      'fieldDescriptions': descriptions,
      'sources': sources,
      'finalValues': values,
    });
  }
  return pairs;
}

String _normalize(String? value) =>
    (value ?? '').trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

Future<void> _writeJson(File file, Object data) =>
    file.writeAsString(_encoder.convert(data));

Future<void> _writeJsonl(File file, List<Map<String, dynamic>> rows) async {
  await file.parent.create(recursive: true);
  await file.writeAsString(rows.map(jsonEncode).join('\n'));
}
