import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:archive/archive.dart';
import 'package:collection/collection.dart'; // Add this import
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
    required Map<String, String?> singleLines,
    Map<String, (String, Size)>? imageReplacements,
  }) async {
    final originalArchive = ZipDecoder().decodeBytes(originalBytes);
    var newArchive = Archive();

    for (final file in originalArchive) {
      if (file.isFile && isValidDocNamePart(file)) {
        final xmlContent = utf8.decode(file.content);
        final document = xml.XmlDocument.parse(xmlContent);
        final textNodes = document.findAllElements('w:t');
        for (final node in textNodes) {
          var text = node.innerText;
          for (final entry in singleLines.entries) {
            final value = entry.value;
            if (text.contains(entry.key)) {
              if (value == null || value.isEmpty) {
                // remove the whole line (the paragraph <w:p> element)
                xml.XmlElement? paragraph =
                    node.ancestors
                        .whereType<xml.XmlElement>()
                        .toList()
                        .where((e) => e.name.local == 'p')
                        .firstOrNull;
                paragraph?.parent?.children.remove(paragraph);
                debugPrint(
                  "singleLines removed this line has key ${entry.key}",
                );
              } else {
                text = text.replaceAll(entry.key, entry.value!);
                debugPrint(
                  "singleLines removed this line has key ${entry.key}",
                );
              }
            }
          }
          for (final entry in replacements.entries) {
            text = text.replaceAll(entry.key, entry.value);
            debugPrint("replace text has key ${entry.key}");
          }

          // ✅ apply the updated text
          node.innerText = text;
        }

        final updatedXml = utf8.encode(document.toXmlString(pretty: false));
        // ✅ use replaceFileInArchive helper
        replaceFileInArchive(newArchive, file.name, updatedXml);
      } else {
        // Copy unchanged files
        newArchive.addFile(ArchiveFile(file.name, file.size, file.content));
      }
    }
    if (imageReplacements != null && imageReplacements.isNotEmpty) {
      debugPrint("replace image start");
      // ⭐️ Re-assign newArchive with the result from the image insertion function
      newArchive = await insertImagesIntoDocxArchived(
        replacements: imageReplacements,
        inputArchive: newArchive, // Pass the text-modified archive
      );
      debugPrint("replace image end");
    }
    return Uint8List.fromList(ZipEncoder().encode(newArchive)!);
  }

  static String docxToText(Uint8List bytes, {bool handleNumbering = false}) {
    final zipDecoder = ZipDecoder();

    final archive = zipDecoder.decodeBytes(bytes);
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

  /// ❗️ REVISED FUNCTION
  /// Takes an archive, adds images, and returns a NEW, modified archive.
  static Future<Archive> insertImagesIntoDocxArchived({
    required Map<String, (String, Size)>
    replacements, // placeholder -> (imagePath, imageSize)
    required Archive inputArchive, // The archive to read from
  }) async {
    // Find the essential XML files within the input archive.
    final documentFileEntry = inputArchive.findFile('word/document.xml');
    final relsFileEntry = inputArchive.findFile('word/_rels/document.xml.rels');
    final contentTypesFileEntry = inputArchive.findFile('[Content_Types].xml');

    if (documentFileEntry == null ||
        relsFileEntry == null ||
        contentTypesFileEntry == null) {
      throw Exception('A required DOCX part is missing from the archive.');
    }

    // Parse the XML content.
    final documentXmlDoc = xml.XmlDocument.parse(
      utf8.decode(documentFileEntry.content),
    );
    final relsXmlDoc = xml.XmlDocument.parse(
      utf8.decode(relsFileEntry.content),
    );
    final contentTypesDoc = xml.XmlDocument.parse(
      utf8.decode(contentTypesFileEntry.content),
    );

    final relationshipsElement = relsXmlDoc.rootElement;
    final typesElement = contentTypesDoc.rootElement;

    // --- Prepare for adding new content ---
    final existingExtensions =
        typesElement
            .findElements('Default')
            .map((e) => e.getAttribute('Extension')?.toLowerCase())
            .whereNotNull()
            .toSet();

    int maxExistingRId = 0;
    relationshipsElement.findElements('Relationship').forEach((rel) {
      final id = rel.getAttribute('Id');
      if (id != null && id.startsWith('rId')) {
        final numVal = int.tryParse(id.substring(3));
        if (numVal != null && numVal > maxExistingRId) {
          maxExistingRId = numVal;
        }
      }
    });

    int imageCounter = maxExistingRId + 1;
    final allTextNodes = documentXmlDoc.findAllElements('w:t').toList();
    final List<ArchiveFile> newMediaFiles = [];

    // Loop through placeholders and prepare image data and XML modifications
    for (final entry in replacements.entries) {
      // (The logic inside this loop remains the same as the previous answer)
      final placeholder = entry.key;
      final imagePath = entry.value.$1;
      final imageSize = entry.value.$2;

      final targetTextNode = allTextNodes.firstWhereOrNull(
        (node) => node.innerText.contains(placeholder),
      );

      if (targetTextNode == null) continue;

      final targetRunNode =
          targetTextNode.ancestors.firstWhereOrNull(
                (n) => n is xml.XmlElement && n.name.local == 'r',
              )
              as xml.XmlElement?;

      if (targetRunNode == null) continue;

      final imageRelId = 'rId$imageCounter';
      final imageFileExtension = p.extension(imagePath).toLowerCase();
      final imageFileName = 'image$imageCounter$imageFileExtension';
      final imageBytes = await File(imagePath).readAsBytes();

      newMediaFiles.add(
        ArchiveFile('word/media/$imageFileName', imageBytes.length, imageBytes),
      );

      relationshipsElement.children.add(
        xml.XmlElement(xml.XmlName('Relationship'), [
          xml.XmlAttribute(xml.XmlName('Id'), imageRelId),
          xml.XmlAttribute(
            xml.XmlName('Type'),
            'http://schemas.openxmlformats.org/officeDocument/2006/relationships/image',
          ),
          xml.XmlAttribute(xml.XmlName('Target'), 'media/$imageFileName'),
        ]),
      );

      final extension = imageFileExtension.substring(1);
      if (!existingExtensions.contains(extension)) {
        final String contentType;
        switch (extension) {
          case 'jpeg':
          case 'jpg':
            contentType = 'image/jpeg';
            break;
          case 'png':
            contentType = 'image/png';
            break;
          default:
            continue;
        }
        typesElement.children.add(
          xml.XmlElement(xml.XmlName('Default'), [
            xml.XmlAttribute(xml.XmlName('Extension'), extension),
            xml.XmlAttribute(xml.XmlName('ContentType'), contentType),
          ]),
        );
        existingExtensions.add(extension);
      }

      final cx = (imageSize.width * 914400).round();
      final cy = (imageSize.height * 914400).round();

      final drawingXmlString =
          '''<w:r xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture"><w:drawing><wp:inline distT="0" distB="0" distL="0" distR="0"><wp:extent cx="$cx" cy="$cy"/><wp:docPr id="$imageCounter" name="Picture $imageCounter"/><a:graphic><a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture"><pic:pic><pic:nvPicPr><pic:cNvPr id="0" name="$imageFileName"/><pic:cNvPicPr/></pic:nvPicPr><pic:blipFill><a:blip r:embed="$imageRelId"/><a:stretch><a:fillRect/></a:stretch></pic:blipFill><pic:spPr><a:xfrm><a:off x="0" y="0"/><a:ext cx="$cx" cy="$cy"/></a:xfrm><a:prstGeom prst="rect"><a:avLst/></a:prstGeom></pic:spPr></pic:pic></a:graphicData></a:graphic></wp:inline></w:drawing></w:r>''';
      final drawingElement =
          xml.XmlDocument.parse(drawingXmlString).rootElement.copy();

      targetRunNode.parent?.children.insert(
        targetRunNode.parent!.children.indexOf(targetRunNode),
        drawingElement,
      );
      targetRunNode.parent?.children.remove(targetRunNode);

      imageCounter++;
    }

    // --- Rebuild the archive ---
    final outputArchive = Archive();

    // 1. Add all original files EXCEPT the ones we've modified
    for (final file in inputArchive.files) {
      if (file.name != 'word/document.xml' &&
          file.name != 'word/_rels/document.xml.rels' &&
          file.name != '[Content_Types].xml') {
        outputArchive.addFile(file);
      }
    }

    // 2. Add the newly generated media files
    for (final mediaFile in newMediaFiles) {
      outputArchive.addFile(mediaFile);
    }

    // 3. Add the updated XML files
    outputArchive.addFile(
      ArchiveFile(
        'word/document.xml',
        utf8.encode(documentXmlDoc.toXmlString()).length,
        utf8.encode(documentXmlDoc.toXmlString()),
      ),
    );
    outputArchive.addFile(
      ArchiveFile(
        'word/_rels/document.xml.rels',
        utf8.encode(relsXmlDoc.toXmlString()).length,
        utf8.encode(relsXmlDoc.toXmlString()),
      ),
    );
    outputArchive.addFile(
      ArchiveFile(
        '[Content_Types].xml',
        utf8.encode(contentTypesDoc.toXmlString()).length,
        utf8.encode(contentTypesDoc.toXmlString()),
      ),
    );

    return outputArchive;
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
