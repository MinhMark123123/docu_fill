import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
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
  static Future<Uint8List> composeModifiedDocxWithPlaceholders({
    required Uint8List originalBytes,
    required Map<String, String> replacements,
    Map<String, (String, Size)>? imageReplacements,
  }) async {
    final originalArchive = ZipDecoder().decodeBytes(originalBytes);
    final newArchive = Archive();

    for (final file in originalArchive) {
      if (file.isFile && isValidDocNamePart(file)) {
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
    if (imageReplacements != null && imageReplacements.isNotEmpty) {
      await insertImagesIntoDocxArchived(
        docxBytes: originalBytes,
        replacements: imageReplacements,
        archive: newArchive,
      );
    }
    return Uint8List.fromList(ZipEncoder().encode(newArchive)!);
  }

  static String docxToText(Uint8List bytes, {bool handleNumbering = false}) {
    final _zipDecoder = ZipDecoder();

    final archive = _zipDecoder.decodeBytes(bytes);
    final List<String> list = [];

    void extractTextFromXml(String xmlContent, {bool handleNumbering = false}) {
      final document = xml.XmlDocument.parse(xmlContent);
      print(document);
      final paragraphNodes = document.findAllElements('w:p');

      int number = 0;
      String lastNumId = '0';

      for (final paragraph in paragraphNodes) {
        final textNodes = paragraph.findAllElements('w:t');
        var text = textNodes.map((node) => node.innerText).join();

        if (handleNumbering) {
          var numbering = paragraph.getElement('w:pPr')?.getElement('w:numPr');
          if (numbering != null) {
            final numId =
                numbering.getElement('w:numId')?.getAttribute('w:val') ?? '';

            if (numId != lastNumId) {
              number = 0;
              lastNumId = numId;
            }
            number++;
            text = '$number. $text';
          }
        }

        if (text.trim().isNotEmpty) {
          list.add(text);
        }
      }
    }

    for (final file in archive) {
      if (file.isFile && isValidDocNamePart(file)) {
        final fileContent = utf8.decode(file.content);
        extractTextFromXml(fileContent, handleNumbering: handleNumbering);
      }
    }

    return list.join('\n');
  }

  static Future<Uint8List> insertImagesIntoDocxArchived({
    required Uint8List docxBytes,
    required Map<String, (String, Size)> replacements, // placeholder -> image
    // path
    required Archive archive,
  }) async {
    // Step 1: Load and modify document.xml
    final documentFile = archive.files.firstWhere(
      (f) => f.name == 'word/document.xml',
    );
    final documentXml = xml.XmlDocument.parse(
      utf8.decode(documentFile.content),
    );

    final allTextNodes = documentXml.findAllElements('w:t').toList();

    int imageIndex = 1;
    final relEntries = <xml.XmlElement>[];

    for (final entry in replacements.entries) {
      final placeholder = entry.key;
      final imagePath = entry.value.$1;
      final widthInInches = entry.value.$2.width;
      final heightInInches = entry.value.$2.height;
      final targetNode = allTextNodes.firstWhere(
        (node) => node.innerText.contains(placeholder),
        orElse: () => throw Exception('Placeholder "$placeholder" not found'),
      );

      final imageRelId = 'rId_image_$imageIndex';
      final imageFileName = 'image$imageIndex${p.extension(imagePath)}';
      final imageMediaPath = 'word/media/$imageFileName';
      // Convert inches → EMUs
      final cx = (widthInInches * 914400).round();
      final cy = (heightInInches * 914400).round();
      // Load image bytes
      final imageBytes = await File(imagePath).readAsBytes();

      // Step 2: Insert <w:drawing> to replace the placeholder
      final drawingXml = '''
<w:r xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
     xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
     xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
     xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing">
  <w:drawing>
    <wp:inline>
      <wp:extent cx="$cx" cy="$cy"/>
      <wp:docPr id="$imageIndex" name="Picture $imageIndex"/>
      <a:graphic>
        <a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">
          <pic:pic xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">
            <pic:blipFill>
              <a:blip r:embed="$imageRelId"/>
              <a:stretch><a:fillRect/></a:stretch>
            </pic:blipFill>
            <pic:spPr>
              <a:xfrm><a:off x="0" y="0"/><a:ext cx="$cx" cy="$cy"/></a:xfrm>
              <a:prstGeom prst="rect"><a:avLst/></a:prstGeom>
            </pic:spPr>
          </pic:pic>
        </a:graphicData>
      </a:graphic>
    </wp:inline>
  </w:drawing>
</w:r>
''';

      final newDrawing = xml.XmlDocument.parse(drawingXml).rootElement;
      targetNode.parent?.replace(newDrawing);

      // Step 3: Add image to media
      archive.addFile(
        ArchiveFile(imageMediaPath, imageBytes.length, imageBytes),
      );

      // Step 4: Create <Relationship> entry for the image
      relEntries.add(
        xml.XmlElement(xml.XmlName('Relationship'), [
          xml.XmlAttribute(xml.XmlName('Id'), imageRelId),
          xml.XmlAttribute(
            xml.XmlName('Type'),
            'http://schemas.openxmlformats.org/officeDocument/2006/relationships/image',
          ),
          xml.XmlAttribute(xml.XmlName('Target'), 'media/$imageFileName'),
        ]),
      );

      imageIndex++;
    }

    // Step 5: Update word/_rels/document.xml.rels
    final relsFile = archive.files.firstWhere(
      (f) => f.name == 'word/_rels/document.xml.rels',
    );
    final relsXml = xml.XmlDocument.parse(utf8.decode(relsFile.content));
    relsXml.rootElement.children.addAll(relEntries);

    // Replace files in archive
    archive.files.removeWhere((f) => f.name == 'word/document.xml');
    archive.files.removeWhere((f) => f.name == 'word/_rels/document.xml.rels');

    archive.addFile(
      ArchiveFile(
        'word/document.xml',
        0,
        utf8.encode(documentXml.toXmlString()),
      ),
    );
    archive.addFile(
      ArchiveFile(
        'word/_rels/document.xml.rels',
        0,
        utf8.encode(relsXml.toXmlString()),
      ),
    );

    return Uint8List.fromList(ZipEncoder().encode(archive)!);
  }

  /// Helper to replace file in archive
  static void replaceFileInArchive(
    Archive archive,
    String filename,
    List<int> newContent,
  ) {
    final index = archive.files.indexWhere((f) => f.name == filename);
    if (index != -1) {
      archive.files.removeAt(index);
    }
    archive.addFile(ArchiveFile(filename, newContent.length, newContent));
  }

  static bool isValidDocNamePart(ArchiveFile file) {
    return (file.name == 'word/document.xml' ||
        file.name.startsWith('word/header') ||
        file.name.startsWith('word/footer'));
  }
}
