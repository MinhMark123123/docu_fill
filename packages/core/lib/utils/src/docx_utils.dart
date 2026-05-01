import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:archive/archive.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart' as xml;

class DocxUtils {
  DocxUtils._();

  static Future<String?> saveDocxToAppDirectory({
    required String originalDocxPath,
    required String newFileName,
    String? customDirectoryName,
  }) async {
    try {
      final File originalFile = File(originalDocxPath);
      if (!await originalFile.exists()) {
        if (kDebugMode) {
          print(
            'Error: Original DOCX file does not exist at $originalDocxPath',
          );
        }
        return null;
      }

      Directory appDir = await getApplicationDocumentsDirectory();
      Directory targetDirectory = appDir;
      if (customDirectoryName != null && customDirectoryName.isNotEmpty) {
        targetDirectory = Directory('${appDir.path}/$customDirectoryName');
        if (!await targetDirectory.exists()) {
          await targetDirectory.create(recursive: true);
        }
      }

      final String newFilePath = '${targetDirectory.path}/$newFileName';
      final File newFile = File(newFilePath);
      await originalFile.copy(newFile.path);
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

    // Copy image replacements to avoid modifying original map
    final Map<String, (String, Size)> activeImageReplacements =
        imageReplacements != null ? Map.from(imageReplacements) : {};

    for (final file in originalArchive) {
      if (file.isFile && isValidDocNamePart(file)) {
        final xmlContent = utf8.decode(file.content);
        final document = xml.XmlDocument.parse(xmlContent);

        // --- STEP 0: Clean up XML to improve placeholder matching ---
        // Remove proofing tags which often split placeholders (e.g. {{<proofErr/>key}})
        final proofNodes = [
          ...document.findAllElements('w:proofErr'),
          ...document.findAllElements('w:noProof'),
        ];
        for (var node in proofNodes) {
          node.parent?.children.remove(node);
        }

        // --- STEP 1: Process Paragraphs ---
        final paragraphs = document.findAllElements('w:p').toList();

        for (int i = 0; i < paragraphs.length; i++) {
          final p = paragraphs[i];

          // Check if this paragraph contains complex objects (OLE, Fields, etc.)
          // We should be very careful with consolidation in these paragraphs.
          bool hasComplexObjects =
              p.findAllElements('w:object').isNotEmpty ||
              p.findAllElements('w:fldChar').isNotEmpty ||
              p.findAllElements('w:instrText').isNotEmpty ||
              p.findAllElements('w:control').isNotEmpty;

          // Get ALL text nodes in the paragraph
          final textNodes = p.findAllElements('w:t').toList();
          if (textNodes.isEmpty) continue;

          // Join text for pattern matching
          final String originalFullText =
              textNodes.map((t) => t.innerText).join();
          String currentText = originalFullText;
          bool textChanged = false;
          bool paragraphRemoved = false;

          // --- STEP 2: Handle Single Line Removals ---
          for (final entry in singleLines.entries) {
            if (currentText.contains(entry.key)) {
              final value = entry.value;
              if (value == null || value.isEmpty) {
                p.parent?.children.remove(p);
                paragraphRemoved = true;

                // Remove next empty paragraph if exists
                if (i + 1 < paragraphs.length) {
                  final nextP = paragraphs[i + 1];
                  if (nextP
                      .findAllElements('w:t')
                      .map((t) => t.innerText)
                      .join()
                      .trim()
                      .isEmpty) {
                    nextP.parent?.children.remove(nextP);
                  }
                }
                break;
              }
            }
          }

          if (paragraphRemoved) continue;

          // --- STEP 3: Handle Text Replacements ---
          // 3a. Simple Replacement: Try to replace within each individual node first (Safest)
          for (var node in textNodes) {
            String nodeText = node.innerText;
            bool nodeChanged = false;

            // Apply standard replacements
            replacements.forEach((key, value) {
              if (nodeText.contains(key)) {
                nodeText = nodeText.replaceAll(key, value);
                nodeChanged = true;
                textChanged = true;
              }
            });

            // Apply singleLine replacements (if they have values)
            singleLines.forEach((key, value) {
              if (value != null && value.isNotEmpty && nodeText.contains(key)) {
                nodeText = nodeText.replaceAll(key, value);
                nodeChanged = true;
                textChanged = true;
              }
            });

            if (nodeChanged) {
              node.innerText = nodeText;
              // Preserve whitespace if needed
              if (nodeText.startsWith(' ') || nodeText.endsWith(' ')) {
                node.setAttribute('xml:space', 'preserve');
              }
            }
          }

          // 3b. Handle Split Placeholders (Only if not already handled and not a complex paragraph)
          // We only consolidate if we detect a placeholder still exists in the joined text
          // that wasn't caught by the individual node replacement.
          bool stillHasPlaceholders = false;
          final combinedText = textNodes.map((t) => t.innerText).join();

          for (var key in [
            ...replacements.keys,
            ...singleLines.keys,
            ...activeImageReplacements.keys,
          ]) {
            if (combinedText.contains(key)) {
              stillHasPlaceholders = true;
              break;
            }
          }

          if (stillHasPlaceholders && !hasComplexObjects) {
            // Consolidate safely: Move all text to first node, clear others
            // ONLY if they are not part of something dangerous.
            // Note: We already checked hasComplexObjects at paragraph level.
            String newCombinedText = combinedText;

            replacements.forEach((key, value) {
              newCombinedText = newCombinedText.replaceAll(key, value);
            });
            singleLines.forEach((key, value) {
              if (value != null && value.isNotEmpty) {
                newCombinedText = newCombinedText.replaceAll(key, value);
              }
            });

            // Update first node and clear others
            textNodes[0].innerText = newCombinedText;
            if (newCombinedText.startsWith(' ') ||
                newCombinedText.endsWith(' ')) {
              textNodes[0].setAttribute('xml:space', 'preserve');
            }
            for (int k = 1; k < textNodes.length; k++) {
              textNodes[k].innerText = '';
            }
            textChanged = true;
          }
        }

        final updatedXml = utf8.encode(document.toXmlString(pretty: false));
        replaceFileInArchive(newArchive, file.name, updatedXml);
      } else {
        newArchive.addFile(ArchiveFile(file.name, file.size, file.content));
      }
    }

    if (activeImageReplacements.isNotEmpty) {
      try {
        newArchive = await insertImagesIntoDocxArchived(
          replacements: activeImageReplacements,
          inputArchive: newArchive,
        );
      } catch (e) {
        debugPrint("Warning: Failed to insert images: $e");
      }
    }

    return Uint8List.fromList(ZipEncoder().encode(newArchive)!);
  }

  static Future<Archive> insertImagesIntoDocxArchived({
    required Map<String, (String, Size)> replacements,
    required Archive inputArchive,
  }) async {
    final documentFileEntry = inputArchive.findFile('word/document.xml');
    final relsFileEntry = inputArchive.findFile('word/_rels/document.xml.rels');
    final contentTypesFileEntry = inputArchive.findFile('[Content_Types].xml');

    if (documentFileEntry == null ||
        relsFileEntry == null ||
        contentTypesFileEntry == null) {
      return inputArchive;
    }

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

    final existingExtensions =
        typesElement
            .findElements('Default')
            .map((e) => e.getAttribute('Extension')?.toLowerCase())
            .nonNulls
            .toSet();

    int maxExistingRId = 0;
    relationshipsElement.findElements('Relationship').forEach((rel) {
      final id = rel.getAttribute('Id');
      if (id != null && id.startsWith('rId')) {
        final numVal = int.tryParse(id.substring(3));
        if (numVal != null && numVal > maxExistingRId) maxExistingRId = numVal;
      }
    });

    int imageCounter = maxExistingRId + 1;
    final List<ArchiveFile> newMediaFiles = [];

    for (final entry in replacements.entries) {
      final placeholder = entry.key;
      final imagePath = entry.value.$1;
      final imageSize = entry.value.$2;

      // Important: find the specific text node for THIS placeholder
      final allTextNodes = documentXmlDoc.findAllElements('w:t').toList();
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

      if (imagePath.isEmpty) {
        final parentParagraph = targetTextNode.ancestors.firstWhereOrNull(
          (n) => n is xml.XmlElement && n.name.local == 'p',
        );
        if (parentParagraph != null) {
          parentParagraph.parent?.children.remove(parentParagraph);
        } else {
          targetTextNode.innerText = '';
        }
        continue;
      }

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

      final extension =
          imageFileExtension.isNotEmpty ? imageFileExtension.substring(1) : '';
      if (extension.isNotEmpty && !existingExtensions.contains(extension)) {
        final String contentType =
            (extension == 'png') ? 'image/png' : 'image/jpeg';
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

      final parent = targetRunNode.parent;
      if (parent != null) {
        parent.children.insert(
          parent.children.indexOf(targetRunNode),
          drawingElement,
        );
        parent.children.remove(targetRunNode);
      }

      imageCounter++;
    }

    final outputArchive = Archive();
    for (final file in inputArchive.files) {
      if (file.name != 'word/document.xml' &&
          file.name != 'word/_rels/document.xml.rels' &&
          file.name != '[Content_Types].xml') {
        outputArchive.addFile(file);
      }
    }
    for (final mediaFile in newMediaFiles) {
      outputArchive.addFile(mediaFile);
    }
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

  static void replaceFileInArchive(
    Archive archive,
    String filename,
    List<int> newContent,
  ) {
    final index = archive.files.indexWhere((f) => f.name == filename);
    if (index != -1) archive.files.removeAt(index);
    archive.addFile(ArchiveFile(filename, newContent.length, newContent));
  }

  static String docxToText(Uint8List bytes, {bool handleNumbering = false}) {
    final archive = ZipDecoder().decodeBytes(bytes);
    final List<String> list = [];
    for (final file in archive) {
      if (file.isFile && isValidDocNamePart(file)) {
        final document = xml.XmlDocument.parse(utf8.decode(file.content));
        for (final paragraph in document.findAllElements('w:p')) {
          final text =
              paragraph
                  .findAllElements('w:t')
                  .map((node) => node.innerText)
                  .join();
          if (text.trim().isNotEmpty) list.add(text);
        }
      }
    }
    return list.join('\n');
  }

  static bool isValidDocNamePart(ArchiveFile file) {
    return (file.name == 'word/document.xml' ||
        file.name.startsWith('word/header') ||
        file.name.startsWith('word/footer'));
  }
}
