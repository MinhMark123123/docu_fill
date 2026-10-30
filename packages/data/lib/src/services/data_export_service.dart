import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:data/src/data_source/export_history_local_data_source.dart';
import 'package:data/src/repositories/settings/settings_repository.dart';
import 'package:data/src/repositories/template/template_repository.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Packs the app data needed to analyse and improve field mapping into one
/// zip: templates, export histories (with source texts and user-confirmed
/// values), settings without the API key, and the Gemini/AI result logs.
///
/// The layout matches the output of tools/data_export, so analysis scripts
/// work on both.
class DataExportService {
  static const formatVersion = 'docu_fill_data/v1';
  static const _logFolders = ['api_logs', 'ai_results'];

  final TemplateRepository _templateRepository;
  final ExportHistoryLocalDataSource _historyDataSource;
  final SettingsRepository _settingsRepository;
  final Future<Directory> Function() _documentsDirectory;

  DataExportService({
    required TemplateRepository templateRepository,
    required ExportHistoryLocalDataSource historyDataSource,
    required SettingsRepository settingsRepository,
    Future<Directory> Function() documentsDirectory =
        getApplicationDocumentsDirectory,
  }) : _templateRepository = templateRepository,
       _historyDataSource = historyDataSource,
       _settingsRepository = settingsRepository,
       _documentsDirectory = documentsDirectory;

  /// Writes the zip into [targetDirectory] and returns its path.
  Future<String> exportAll(String targetDirectory) async {
    final machine = Platform.localHostname;
    final stamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final zipPath = p.join(
      targetDirectory,
      'docu_fill_data_${machine}_$stamp.zip',
    );

    final templates = await _templateRepository.getAllTemplates();
    final histories = await _historyDataSource.getAllHistories();
    final settings = await _settingsRepository.getSettings();

    final encoder = ZipFileEncoder()..create(zipPath);
    try {
      _addJson(encoder, 'templates.json', [
        for (final template in templates) template.toJson(),
      ]);
      _addJson(encoder, 'export_histories.json', [
        for (final model in histories)
          {
            ...model.toDomain().toJson(),
            'id': model.id,
            // toDomain() fills a missing createdAt with "now"; keep the
            // stored value so old records are recognisable.
            'createdAt': model.createdAt?.toIso8601String(),
          },
      ]);
      _addJson(encoder, 'settings.json', {
        'geminiApiKey':
            (settings?.geminiApiKey?.isNotEmpty ?? false) ? '<redacted>' : null,
        'geminiModel': settings?.geminiModel,
        'geminiStudyData': settings?.geminiStudyData,
        'geminiSampleResult': settings?.geminiSampleResult,
        'enableApiLogging': settings?.enableApiLogging,
      });

      final documents = await _documentsDirectory();
      final logCounts = <String, int>{};
      for (final folder in _logFolders) {
        logCounts[folder] = await _addFolder(
          encoder,
          Directory(p.join(documents.path, folder)),
          folder,
        );
      }

      _addJson(encoder, 'manifest.json', {
        'format': formatVersion,
        'machine': machine,
        'user': Platform.environment['USERNAME'],
        'exportedAt': DateTime.now().toIso8601String(),
        'templates': templates.length,
        'histories': histories.length,
        'historiesWithSources':
            histories.where((h) => (h.sourcesJson ?? '[]') != '[]').length,
        ...logCounts,
      });
    } finally {
      encoder.close();
    }
    return zipPath;
  }

  void _addJson(ZipFileEncoder encoder, String name, Object data) {
    final bytes = utf8.encode(const JsonEncoder.withIndent('  ').convert(data));
    encoder.addArchiveFile(ArchiveFile(name, bytes.length, bytes));
  }

  Future<int> _addFolder(
    ZipFileEncoder encoder,
    Directory directory,
    String name,
  ) async {
    if (!await directory.exists()) return 0;
    var count = 0;
    await for (final entity in directory.list()) {
      if (entity is! File) continue;
      await encoder.addFile(entity, '$name/${p.basename(entity.path)}');
      count++;
    }
    return count;
  }
}
