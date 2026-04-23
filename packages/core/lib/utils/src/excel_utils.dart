import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';

class ExcelUtils {
  ExcelUtils._();

  /// Create a new XLSX file by replacing placeholders like {{name}} in the original file.
  static Future<Uint8List> composeModifiedExcel({
    required Uint8List originalBytes,
    required Map<String, String> replacements,
  }) async {
    try {
      // Decode the Excel file
      var excel = Excel.decodeBytes(originalBytes);

      // Iterate through all sheets
      for (var table in excel.tables.keys) {
        var sheet = excel.tables[table]!;

        // Iterate through all rows and cells
        for (var row in sheet.rows) {
          for (var cell in row) {
            if (cell != null && cell.value != null) {
              // Get string representation of cell value
              String cellText = cell.value.toString();
              bool changed = false;

              // Check for each placeholder in the replacements map
              replacements.forEach((key, value) {
                if (cellText.contains(key)) {
                  cellText = cellText.replaceAll(key, value);
                  changed = true;
                }
              });

              // If any replacement was made, update the cell value
              if (changed) {
                // In modern 'excel' package versions, strings are set using TextCellValue
                cell.value = TextCellValue(cellText);
              }
            }
          }
        }
      }

      // Encode and return the modified bytes
      final encoded = excel.encode();
      return Uint8List.fromList(encoded ?? []);
    } catch (e) {
      debugPrint('Error modifying Excel file: $e');
      // Return original bytes if an error occurs to avoid data loss
      return originalBytes;
    }
  }
}
