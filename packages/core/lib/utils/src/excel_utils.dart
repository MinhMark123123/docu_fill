import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:xml/xml.dart' as xml;

class ExcelUtils {
  ExcelUtils._();

  /// Create a new XLSX file by replacing placeholders like {{name}} in the original file.
  static Future<Uint8List> composeModifiedExcel({
    required Uint8List originalBytes,
    required Map<String, String> replacements,
  }) async {
    try {
      final archive = ZipDecoder().decodeBytes(originalBytes);
      final newArchive = Archive();
      bool modified = false;

      for (final file in archive) {
        if (file.isFile &&
            (file.name == 'xl/sharedStrings.xml' ||
                file.name.startsWith('xl/worksheets/sheet'))) {
          try {
            final content = file.content as List<int>;
            final xmlContent = utf8.decode(content);
            final document = xml.XmlDocument.parse(xmlContent);
            bool changed = false;

            // Target specifically text and formula tags in Excel XML structure
            // <t> is for text (shared strings or inline)
            // <f> is for formulas
            final excelTextNodes = document.findAllElements('t');
            final formulaNodes = document.findAllElements('f');

            final allNodes = [...excelTextNodes, ...formulaNodes];

            for (var node in allNodes) {
              String nodeText = node.innerText;
              bool nodeChanged = false;

              replacements.forEach((key, value) {
                if (nodeText.contains(key)) {
                  nodeText = nodeText.replaceAll(key, value);
                  nodeChanged = true;
                  changed = true;
                }
              });

              if (nodeChanged) {
                node.children.clear();
                node.children.add(xml.XmlText(nodeText));
              }
            }

            if (changed) {
              final updatedBytes = utf8.encode(
                document.toXmlString(pretty: false),
              );
              final newFile = ArchiveFile(
                file.name,
                updatedBytes.length,
                updatedBytes,
              );
              _copyFileAttributes(file, newFile);
              newArchive.addFile(newFile);
              modified = true;
            } else {
              newArchive.addFile(file);
            }
          } catch (e) {
            debugPrint('Error parsing XML in Excel file (${file.name}): $e');
            newArchive.addFile(file);
          }
        } else {
          newArchive.addFile(file);
        }
      }

      if (modified) {
        final encoded = ZipEncoder().encode(newArchive);
        if (encoded != null) {
          return Uint8List.fromList(encoded);
        }
      }
    } catch (e) {
      debugPrint('Note: ZIP-based Excel modification failed, falling back: $e');
    }

    return _composeWithExcelPackage(originalBytes, replacements);
  }

  static void _copyFileAttributes(ArchiveFile source, ArchiveFile target) {
    target.mode = source.mode;
    target.lastModTime = source.lastModTime;
  }

  static Future<Uint8List> _composeWithExcelPackage(
    Uint8List originalBytes,
    Map<String, String> replacements,
  ) async {
    try {
      var excel = Excel.decodeBytes(originalBytes);
      for (var table in excel.tables.keys) {
        var sheet = excel.tables[table]!;
        for (var row in sheet.rows) {
          for (var cell in row) {
            if (cell != null && cell.value != null) {
              final originalValue = cell.value;
              String cellText = originalValue.toString();
              bool isFormula = originalValue is FormulaCellValue;
              bool changed = false;

              replacements.forEach((key, value) {
                if (cellText.contains(key)) {
                  cellText = cellText.replaceAll(key, value);
                  changed = true;
                }
              });

              if (changed) {
                if (isFormula) {
                  cell.value = FormulaCellValue(cellText);
                } else {
                  cell.value = TextCellValue(cellText);
                }
              }
            }
          }
        }
      }
      final encoded = excel.encode();
      return Uint8List.fromList(encoded ?? []);
    } catch (e) {
      debugPrint('Error modifying Excel file via package: $e');
      return originalBytes;
    }
  }
}
