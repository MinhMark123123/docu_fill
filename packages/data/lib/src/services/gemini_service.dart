import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:data/data.dart';
import 'package:data/src/repositories/settings/settings_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:googleai_dart/googleai_dart.dart' hide File;
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class GeminiService {
  final SettingsRepository _settingsRepository;

  GeminiService(this._settingsRepository);

  Future<Map<String, String>> mapTextToTemplate({
    required String rawText,
    required Map<String, String?>
    templateConfig, // Key: FieldKey, Value: Description (optional)
  }) async {
    final settings = await _settingsRepository.getSettings();
    final apiKey = settings?.geminiApiKey;

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(
        'Gemini API Key is not configured. Please set it in settings.',
      );
    }

    final modelName = settings?.geminiModel ?? 'gemini-1.5-flash';

    // Format fields description for prompt
    final fieldDescriptions = templateConfig.entries
        .map((e) {
          return "- Key: \"${e.key}\" ${e.value != null && e.value!.isNotEmpty ? "(Description: ${e.value})" : ""}";
        })
        .join('\n');

    final studyData = settings?.geminiStudyData;
    final sampleResult = settings?.geminiSampleResult;

    final prompt = '''
You are an expert data extraction assistant.
${studyData != null && studyData.isNotEmpty ? "CONTEXT/STUDY DATA:\n$studyData\n" : ""}
You will be provided with "EXTRACTED TEXT" from a document and a list of "FIELD KEYS" with optional descriptions.
Your goal is to map the information from the text into the field keys accurately.

RULES:
1. Return ONLY a valid JSON object.
2. The keys in the JSON must exactly match the "FIELD KEYS" provided.
3. Values should be extracted from the "EXTRACTED TEXT".
4. If a value represents a date, format it as "DD-MM-YYYY" if possible.
5. If a value is not found in the text, return an empty string "" for that key.
6. Use the descriptions provided for each key to better understand what to extract.
${sampleResult != null && sampleResult.isNotEmpty ? "7. Follow the format of this SAMPLE RESULT:\n$sampleResult\n" : ""}

FIELD KEYS:
$fieldDescriptions

EXTRACTED TEXT:
$rawText

JSON OUTPUT:
''';

    final client = GoogleAIClient.withApiKey(apiKey);
    String? responseText;
    Object? error;
    try {
      final content = [
        Content(role: 'user', parts: [TextPart(prompt)]),
      ];
      final response = await client.models.generateContent(
        model: modelName,
        request: GenerateContentRequest(contents: content),
      );
      responseText = response.text;
      if (responseText == null) {
        throw Exception('Gemini response was empty');
      }

      final startIndex = responseText.indexOf('{');
      final endIndex = responseText.lastIndexOf('}');
      if (startIndex != -1 && endIndex != -1) {
        final jsonPart = responseText.substring(startIndex, endIndex + 1);
        final Map<String, dynamic> decoded = jsonDecode(jsonPart);
        return decoded.map((key, value) => MapEntry(key, value.toString()));
      }
      throw Exception('Could not find JSON in Gemini response');
    } catch (e) {
      error = e;
      rethrow;
    } finally {
      client.close();
      if (settings?.enableApiLogging ?? false) {
        await _logToFile(prompt, responseText, error: error);
      }
    }
  }

  Future<Map<String, String>> mapFileToTemplate({
    required Uint8List fileBytes,
    required String fileName,
    required Map<String, String?>
    templateConfig, // Key: FieldKey, Value: Description (optional)
  }) async {
    final settings = await _settingsRepository.getSettings();
    final apiKey = settings?.geminiApiKey;

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(
        'Gemini API Key is not configured. Please set it in settings.',
      );
    }

    final modelName = settings?.geminiModel ?? 'gemini-1.5-flash';

    // Format fields description for prompt
    final fieldDescriptions = templateConfig.entries
        .map((e) {
          return "- Key: \"${e.key}\" ${e.value != null && e.value!.isNotEmpty ? "(Description: ${e.value})" : ""}";
        })
        .join('\n');

    final studyData = settings?.geminiStudyData;
    final sampleResult = settings?.geminiSampleResult;

    final mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';

    final prompt = '''
You are an expert data extraction assistant.
${studyData != null && studyData.isNotEmpty ? "CONTEXT/STUDY DATA:\n$studyData\n" : ""}
You are provided with a DOCUMENT FILE and a list of "FIELD KEYS" with optional descriptions.
Your goal is to analyze the content of the file and map the information into the field keys.

RULES:
1. Return ONLY a valid JSON object.
2. The keys in the JSON must exactly match the "FIELD KEYS" provided.
3. If a value represents a date, format it as "DD-MM-YYYY".
4. If a value is not found in the file, return an empty string "" for that key.
5. Extract values in their original language found in the document.
6. Use the descriptions provided for each key to better understand what to extract.
${sampleResult != null && sampleResult.isNotEmpty ? "7. Follow the format of this SAMPLE RESULT:\n$sampleResult\n" : ""}

FIELD KEYS:
$fieldDescriptions

JSON OUTPUT:
''';

    final client = GoogleAIClient.withApiKey(apiKey);
    String? responseText;
    Object? error;
    try {
      final content = [
        Content(
          role: 'user',
          parts: [
            TextPart(prompt),
            InlineDataPart(Blob.fromBytes(mimeType, fileBytes)),
          ],
        ),
      ];
      final response = await client.models.generateContent(
        model: modelName,
        request: GenerateContentRequest(contents: content),
      );
      responseText = response.text;

      if (responseText == null) {
        throw Exception('Gemini response was empty');
      }

      final startIndex = responseText.indexOf('{');
      final endIndex = responseText.lastIndexOf('}');

      if (startIndex != -1 && endIndex != -1) {
        final jsonPart = responseText.substring(startIndex, endIndex + 1);
        final Map<String, dynamic> decoded = jsonDecode(jsonPart);
        return decoded.map((key, value) => MapEntry(key, value.toString()));
      }

      throw Exception('Could not find a valid JSON object in Gemini response');
    } catch (e) {
      error = e;
      throw Exception('Failed to process file with Gemini: $e');
    } finally {
      client.close();
      if (settings?.enableApiLogging ?? false) {
        await _logToFile(
          'FILE_UPLOAD_PROMPT: $fileName\n$prompt',
          responseText,
          error: error,
        );
      }
    }
  }

  Future<void> _logToFile(
    String prompt,
    String? response, {
    Object? error,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logsPath = p.join(directory.path, 'api_logs');
      final logsDir = Directory(logsPath);

      if (!await logsDir.exists()) {
        await logsDir.create(recursive: true);
      }

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final status = error != null ? 'ERROR' : 'SUCCESS';
      final logFile = File(p.join(logsPath, 'log_${timestamp}_$status.txt'));

      final content = '''
      --- GEMINI API LOG ---
      TIMESTAMP: ${DateTime.now()}
      STATUS: $status
      ${error != null ? 'ERROR: $error\n' : ''}
      --- PROMPT ---
      $prompt
      
      --- RESPONSE ---
      ${response ?? 'N/A'}
      ----------------------
      ''';

      await logFile.writeAsString(content);
    } catch (e) {
      debugPrint("Error writing log file: $e");
    }
  }

  Future<List<String>> getAvailableModels({String? apiKey}) async {
    final key =
        apiKey ?? (await _settingsRepository.getSettings())?.geminiApiKey;
    if (key == null || key.isEmpty) {
      return [];
    }

    final client = GoogleAIClient.withApiKey(key);
    try {
      final response = await client.models.list();
      final list =
          response.models
              .where(
                (m) =>
                    m.supportedGenerationMethods?.contains('generateContent') ??
                    false,
              )
              .map((m) => m.name)
              .where((name) => name.isNotEmpty)
              .map(
                (name) => name.startsWith('models/') ? name.substring(7) : name,
              )
              .toList();
      return list;
    } catch (e) {
      debugPrint("Error fetching available models from Gemini API: $e");
      rethrow;
    } finally {
      client.close();
    }
  }
}
