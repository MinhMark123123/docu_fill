import 'dart:io';
import 'package:docu_fill/utils/utils.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter/foundation.dart';

class DataExtractionService {
  Future<String> extractText(File file) async {
    final extension = file.path.split('.').last.toLowerCase();

    switch (extension) {
      case 'docx':
        return _extractFromDocx(file);
      case 'xlsx':
      case 'xls':
      case 'ods':
        return _extractFromExcel(file);
      case 'pdf':
        return _extractFromPdf(file);
      default:
        throw Exception('Unsupported file format: $extension');
    }
  }

  Future<String> _extractFromDocx(File file) async {
    try {
      final bytes = await file.readAsBytes();
      return DocxUtils.docxToText(bytes);
    } catch (e) {
      debugPrint('Error extracting from DOCX: $e');
      return '';
    }
  }

  Future<String> _extractFromExcel(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final decoder = SpreadsheetDecoder.decodeBytes(bytes);
      final StringBuffer buffer = StringBuffer();

      for (var table in decoder.tables.keys) {
        buffer.writeln('--- Sheet: $table ---');
        final sheet = decoder.tables[table];
        if (sheet == null) continue;

        for (var row in sheet.rows) {
          final rowData = row.map((cell) => cell?.toString() ?? '').join(' | ');
          if (rowData.trim().isNotEmpty) {
            buffer.writeln(rowData);
          }
        }
      }
      return buffer.toString();
    } catch (e) {
      debugPrint('Error extracting from Excel: $e');
      rethrow;
    }
  }



  Future<String> _extractFromPdf(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      final PdfTextExtractor extractor = PdfTextExtractor(document);
      final String text = extractor.extractText();
      document.dispose();
      return text;
    } catch (e) {
      debugPrint('Error extracting from PDF: $e');
      return '';
    }
  }
}
