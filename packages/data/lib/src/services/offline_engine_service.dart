import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:data/data.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Progress line of the engine ("PROGRESS {...}" on stderr).
class EngineProgress {
  /// load_ocr, ocr_page, learn_rules, apply_rules, load_llm, llm
  final String stage;
  final int done;
  final int total;

  const EngineProgress(this.stage, this.done, this.total);
}

/// One value proposed by the offline engine.
class EngineValue {
  final String value;

  /// "rule" (learned from past exports) or "llm" (local model).
  final String source;
  final double confidence;

  /// The user should check this value before exporting.
  final bool review;

  const EngineValue({
    required this.value,
    required this.source,
    required this.confidence,
    required this.review,
  });

  factory EngineValue.fromJson(Map<String, dynamic> json) => EngineValue(
    value: json['value'] as String,
    source: json['source'] as String,
    confidence: (json['confidence'] as num).toDouble(),
    review: json['review'] as bool,
  );
}

/// Runs the bundled offline engine (`engine/docufill_engine.exe` next to the
/// app) for PDF OCR and field mapping. Nothing is sent over the network: the
/// engine blocks sockets and loads its models from its own folder.
///
/// Requests and results go through temporary JSON files that are deleted
/// right after each call, since they contain customer data.
///
/// For development, set DOCUFILL_ENGINE to `engine/docufill_engine.py` and
/// DOCUFILL_PYTHON to the Python of `tools/ocr_bench/.venv`.
class OfflineEngineService {
  final ExportHistoryRepository _historyRepository;
  final Future<Directory> Function() _documentsDirectory;
  final List<String>? _engineCommand;

  OfflineEngineService(
    this._historyRepository, {
    Future<Directory> Function()? documentsDirectory,
    List<String>? engineCommand,
  }) : _documentsDirectory =
           documentsDirectory ?? getApplicationDocumentsDirectory,
       _engineCommand = engineCommand;

  /// Folder where cases from other machines (dataset.jsonl from
  /// tools/data_export, or export_histories.json from the in-app data export)
  /// can be dropped to learn from them too.
  static const sharedCasesFolder = 'engine_cases';

  List<String>? _command() {
    if (_engineCommand != null) return _engineCommand;
    final override = Platform.environment['DOCUFILL_ENGINE'];
    if (override != null && override.isNotEmpty) {
      if (override.endsWith('.py')) {
        final python = Platform.environment['DOCUFILL_PYTHON'] ?? 'python';
        return [python, '-I', override];
      }
      return [override];
    }
    final exe = p.join(
      p.dirname(Platform.resolvedExecutable),
      'engine',
      'docufill_engine.exe',
    );
    return File(exe).existsSync() ? [exe] : null;
  }

  bool get isInstalled => _command() != null;

  /// OCR of a scanned PDF into rows of " | "-separated cells.
  Future<String> ocrPdf(
    File pdf, {
    void Function(EngineProgress)? onProgress,
  }) async {
    final result = await _run(
      ['ocr', '--input', pdf.path],
      onProgress: onProgress,
    );
    return result['text'] as String;
  }

  /// Maps source text to template keys with rules learned from past exports,
  /// and optionally the local LLM for keys the rules leave empty.
  Future<Map<String, EngineValue>> mapText({
    required String text,
    required Map<String, String?> fields,
    required bool useLlm,
    void Function(EngineProgress)? onProgress,
  }) async {
    final request = {
      'text': text,
      'fields': fields.map((k, v) => MapEntry(k, v ?? '')),
      'cases': await _localCases(),
      'case_files': await _sharedCaseFiles(),
    };
    final temp = await _tempDir();
    final requestFile = File(p.join(temp.path, 'request.json'));
    try {
      await requestFile.writeAsString(jsonEncode(request));
      final result = await _run(
        ['map', '--request', requestFile.path, if (useLlm) '--llm'],
        onProgress: onProgress,
        temp: temp,
      );
      final values = result['values'] as Map<String, dynamic>;
      return values.map(
        (k, v) => MapEntry(k, EngineValue.fromJson(v as Map<String, dynamic>)),
      );
    } finally {
      await _deleteQuietly(temp);
    }
  }

  /// Past exports of this machine with their source text.
  Future<List<Map<String, dynamic>>> _localCases() async {
    final histories = await _historyRepository.getAllHistories();
    final cases = <Map<String, dynamic>>[];
    for (final history in histories) {
      final text = history.sources
          .map((s) => s.text)
          .where((t) => t.isNotEmpty)
          .join('\n');
      if (text.isEmpty) continue;
      final values = <String, String>{};
      for (final entries in [history.fieldValues, history.singleLineValues]) {
        entries.forEach((key, entry) {
          final value = entry.value;
          if (value != null && value.isNotEmpty) values[key] = value;
        });
      }
      cases.add({'text': text, 'values': values});
    }
    return cases;
  }

  Future<List<String>> _sharedCaseFiles() async {
    final docs = await _documentsDirectory();
    final dir = Directory(p.join(docs.path, sharedCasesFolder));
    if (!await dir.exists()) return [];
    return dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.jsonl') || f.path.endsWith('.json'))
        .map((f) => f.path)
        .toList();
  }

  Future<Directory> _tempDir() =>
      Directory.systemTemp.createTemp('docu_fill_engine_');

  Future<Map<String, dynamic>> _run(
    List<String> args, {
    void Function(EngineProgress)? onProgress,
    Directory? temp,
  }) async {
    final command = _command();
    if (command == null) {
      throw Exception('Offline engine is not installed');
    }
    final ownTemp = temp == null;
    final dir = temp ?? await _tempDir();
    final output = File(p.join(dir.path, 'result.json'));
    try {
      final process = await Process.start(command.first, [
        ...command.skip(1),
        ...args,
        '--output',
        output.path,
      ], environment: {'PYTHONIOENCODING': 'utf-8'});
      // stdout is unused; drain it so the child never blocks on a full pipe.
      unawaited(process.stdout.drain<void>());
      String? error;
      final stderrDone = process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
            if (line.startsWith('PROGRESS ')) {
              final json = jsonDecode(line.substring(9)) as Map<String, dynamic>;
              onProgress?.call(
                EngineProgress(
                  json['stage'] as String,
                  json['done'] as int,
                  json['total'] as int,
                ),
              );
            } else if (line.startsWith('ERROR ')) {
              error = line.substring(6);
            } else {
              debugPrint('engine: $line');
            }
          })
          .asFuture<void>();
      final exitCode = await process.exitCode;
      await stderrDone;
      if (exitCode != 0 || !await output.exists()) {
        throw Exception(error ?? 'Offline engine failed (exit code $exitCode)');
      }
      return jsonDecode(await output.readAsString()) as Map<String, dynamic>;
    } finally {
      if (ownTemp) await _deleteQuietly(dir);
    }
  }

  Future<void> _deleteQuietly(Directory dir) async {
    try {
      await dir.delete(recursive: true);
    } catch (e) {
      debugPrint('Could not delete engine temp folder: $e');
    }
  }
}
