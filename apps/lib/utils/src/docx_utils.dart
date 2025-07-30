import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart' as xml;

class DocxUtils {
  DocxUtils._();
  // Function to copy the .docx file to a new app directory
  // Returns the path to the newly saved file, or null on error.
  static Future<String?> saveDocxToAppDirectory({
    required String originalDocxPath, // Full path to the source .docx file
    required String newFileName, // e.g., "template_copy.docx"
    String? customDirectoryName, // Optional: e.g., "templates" or "documents"
  }) async {
    try {
      // 1. Get the source file
      final File originalFile = File(originalDocxPath);
      if (!await originalFile.exists()) {
        if (kDebugMode) {
          print(
            'Error: Original DOCX file does not exist at $originalDocxPath',
          );
        }
        return null;
      }

      // 2. Determine the target directory
      Directory appDir;
      // For storing user-private files. These are backed up by the OS.
      // Use getApplicationSupportDirectory() for files not directly user-facing but needed by the app.
      appDir = await getApplicationDocumentsDirectory();

      // Optional: Create a custom subdirectory within the app documents directory
      Directory targetDirectory = appDir;
      if (customDirectoryName != null && customDirectoryName.isNotEmpty) {
        targetDirectory = Directory('${appDir.path}/$customDirectoryName');
        if (!await targetDirectory.exists()) {
          await targetDirectory.create(
            recursive: true,
          ); // Create if it doesn't exist
          if (kDebugMode) {
            print('Created custom directory: ${targetDirectory.path}');
          }
        }
      }

      // 3. Construct the new file path
      final String newFilePath = '${targetDirectory.path}/$newFileName';
      final File newFile = File(newFilePath);

      // 4. Copy the file
      // The `copy` method returns a Future<File> with the new file instance
      await originalFile.copy(newFile.path);

      if (kDebugMode) {
        print('DOCX file copied successfully to: ${newFile.path}');
      }
      return newFile.path;
    } catch (e) {
      if (kDebugMode) {
        print('Error saving DOCX file: $e');
      }
      return null;
    }
  }

  /// Create a new DOCX file by replacing placeholders like {{name}} in the original file.
  static Uint8List composeModifiedDocxWithPlaceholders(
    Uint8List originalBytes,
    Map<String, String> replacements,
  ) {
    final originalArchive = ZipDecoder().decodeBytes(originalBytes);
    final newArchive = Archive();

    for (final file in originalArchive) {
      if (file.isFile && file.name == 'word/document.xml') {
        final xmlContent = utf8.decode(file.content);
        final document = xml.XmlDocument.parse(xmlContent);

        final textNodes = document.findAllElements('w:t');
        for (final node in textNodes) {
          var text = node.innerText;

          for (final entry in replacements.entries) {
            text = text.replaceAll(entry.key, entry.value);
          }

          node.innerText = text;
        }

        final updatedXml = utf8.encode(document.toXmlString());
        newArchive.addFile(
          ArchiveFile(file.name, updatedXml.length, updatedXml),
        );
      } else {
        // Copy all other files as-is
        newArchive.addFile(ArchiveFile(file.name, file.size, file.content));
      }
    }

    return Uint8List.fromList(ZipEncoder().encode(newArchive)!);
  }
}
