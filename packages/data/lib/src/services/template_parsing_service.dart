import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:core/const/const.dart';
import 'package:core/utils/utils.dart';
import 'package:data/data.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

class TemplateParsingService {
  /// Extracts field keys from a text string based on the defined placeholder regex.
  Set<String> extractFieldsFromText(String text) {
    final regex = RegExp(AppConst.placeHolderRegex);
    return regex.allMatches(text).map((e) => e.group(1)!).toSet();
  }

  /// Parses a Docx file and returns the extracted text.
  Future<String> parseDocx(File file) async {
    final bytes = await file.readAsBytes();
    return DocxUtils.docxToText(bytes);
  }

  /// Parses an Excel file and returns the extracted text from all sheets.
  Future<String> parseExcel(File file) async {
    final bytes = await file.readAsBytes();
    final decoder = SpreadsheetDecoder.decodeBytes(bytes);
    final StringBuffer buffer = StringBuffer();

    for (var table in decoder.tables.keys) {
      final sheet = decoder.tables[table];
      if (sheet == null) continue;
      for (var row in sheet.rows) {
        final rowData = row.map((cell) => cell?.toString() ?? '').join(' ');
        buffer.writeln(rowData);
      }
    }
    return buffer.toString();
  }

  /// Extracts files from a template zip archive and returns the config and document path.
  Future<({TemplateConfig config, String docPath})?> parseTemplateArchive(
    File zipFile,
    Directory extractDir,
  ) async {
    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    if (extractDir.existsSync()) {
      extractDir.deleteSync(recursive: true);
    }
    await extractDir.create(recursive: true);

    File? configFile;
    File? docFile;

    for (final file in archive) {
      if (!file.isFile) continue;

      final data = file.content as List<int>;
      final extractedFile = File(p.join(extractDir.path, file.name));
      await extractedFile.writeAsBytes(data);

      if (file.name.endsWith(AppConst.settingJsonFileName)) {
        configFile = extractedFile;
      } else if (isTemplateDocument(file.name)) {
        docFile = extractedFile;
      }
    }

    if (configFile != null && docFile != null) {
      final jsonString = await configFile.readAsString();
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return (config: TemplateConfig.fromJson(jsonMap), docPath: docFile.path);
    }
    return null;
  }

  bool isTemplateDocument(String filename) {
    return filename.endsWith(AppConst.settingDocFileName) ||
        filename.endsWith('.docx') ||
        filename.endsWith('.xlsx');
  }

  /// Decodes a zip archive from bytes and finds the template JSON.
  TemplateConfig? findConfigInArchive(List<int> bytes) {
    final archive = ZipDecoder().decodeBytes(bytes);
    for (final file in archive) {
      if (file.isFile && file.name.endsWith(AppConst.settingJsonFileName)) {
        final jsonString = utf8.decode(file.content as List<int>);
        return TemplateConfig.fromJson(jsonDecode(jsonString));
      }
    }
    return null;
  }
}
