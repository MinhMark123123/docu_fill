import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:data/data.dart';
import 'package:data/src/repositories/settings/settings_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';

class GeminiService {
  final SettingsRepository _settingsRepository;

  GeminiService(this._settingsRepository);

  Future<Map<String, String>> mapTextToTemplate({
    required String rawText,
    required Map<String, dynamic> templateConfig,
  }) async {
    final settings = await _settingsRepository.getSettings();
    final apiKey = settings?.geminiApiKey;

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(
        'Gemini API Key is not configured. Please set it in settings.',
      );
    }

    final modelName = settings?.geminiModel ?? 'gemini-1.5-flash';
    final model = GenerativeModel(model: modelName, apiKey: apiKey);

    final fieldKeys = templateConfig.keys.toList();

    final prompt = '''
You are an expert data extraction assistant.
You will be provided with "EXTRACTED TEXT" from a document and a list of "FIELD KEYS" from a template.
Your goal is to map the information from the text into the field keys.

RULES:
1. Return ONLY a valid JSON object.
2. The keys in the JSON must exactly match the "FIELD KEYS" provided.
3. Values should be extracted from the "EXTRACTED TEXT".
4. If a value represents a date, format it as "YYYY-MM-DD" if possible.
5. If a value is not found in the text, return an empty string "" for that key.

FIELD KEYS:
${fieldKeys.join(', ')}

EXTRACTED TEXT:
$rawText

JSON OUTPUT:
''';

    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);

    final responseText = response.text;
    if (responseText == null) {
      throw Exception('Gemini response was empty');
    }
    // const responseText = "{}"; // DEBUG: Dummy response for prompt verification

    if (settings?.enableApiLogging ?? false) {
      await _logToFile(prompt, responseText);
    }

    // Attempt to parse JSON
    try {
      final startIndex = responseText.indexOf('{');
      final endIndex = responseText.lastIndexOf('}');
      if (startIndex != -1 && endIndex != -1) {
        final jsonPart = responseText.substring(startIndex, endIndex + 1);
        final Map<String, dynamic> decoded = jsonDecode(jsonPart);
        return decoded.map((key, value) => MapEntry(key, value.toString()));
      }
      throw Exception('Could not find JSON in Gemini response');
    } catch (e) {
      throw Exception(
        'Failed to parse Gemini response: $e\nResponse: $responseText',
      );
    }
  }

  /// Maps document file content to a structured JSON template using Gemini Multimodal API.
  Future<Map<String, String>> mapFileToTemplate({
    required Uint8List fileBytes,
    required String fileName,
    required Map<String, dynamic> templateConfig,
  }) async {
    // 1. Retrieve configuration from repository
    final settings = await _settingsRepository.getSettings();
    final apiKey = settings?.geminiApiKey;

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception(
        'Gemini API Key is not configured. Please set it in settings.',
      );
    }

    // 2. Initialize the Generative Model (Recommend using gemini-1.5-flash for document processing)
    final modelName = settings?.geminiModel ?? 'gemini-1.5-flash';
    final model = GenerativeModel(model: modelName, apiKey: apiKey);

    final fieldKeys = templateConfig.keys.toList();

    // 3. Determine the MIME type of the file (e.g., 'application/pdf', 'image/jpeg')
    final mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';

    // 4. Construct the multimodal prompt
    final prompt = '''
You are an expert data extraction assistant.
You are provided with a DOCUMENT FILE and a list of "FIELD KEYS".
Your goal is to analyze the content of the file and map the information into the field keys.

RULES:
1. Return ONLY a valid JSON object.
2. The keys in the JSON must exactly match the "FIELD KEYS" provided.
3. If a value represents a date, format it as "YYYY-MM-DD".
4. If a value is not found in the file, return an empty string "" for that key.
5. Extract values in their original language found in the document.

FIELD KEYS:
${fieldKeys.join(', ')}

JSON OUTPUT:
''';

    // 5. Create multi-part content containing both text prompt and binary data
    final content = [
      Content.multi([TextPart(prompt), DataPart(mimeType, fileBytes)]),
    ];

    try {
      // 6. Request content generation from Gemini
      final response = await model.generateContent(content);
      final responseText = response.text;

      if (responseText == null) {
        throw Exception('Gemini response was empty');
      }

      // 7. Optional logging for debugging purposes
      if (settings?.enableApiLogging ?? false) {
        await _logToFile(
          'FILE_UPLOAD_PROMPT: $fileName\n$prompt',
          responseText,
        );
      }

      // 8. Parse and validate the JSON output
      final startIndex = responseText.indexOf('{');
      final endIndex = responseText.lastIndexOf('}');

      if (startIndex != -1 && endIndex != -1) {
        final jsonPart = responseText.substring(startIndex, endIndex + 1);
        final Map<String, dynamic> decoded = jsonDecode(jsonPart);

        // Convert all values to String to match the expected return type
        return decoded.map((key, value) => MapEntry(key, value.toString()));
      }

      throw Exception('Could not find a valid JSON object in Gemini response');
    } catch (e) {
      throw Exception('Failed to process file with Gemini: $e');
    }
  }

  Future<void> _logToFile(String prompt, String response) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logsPath = "${directory.path}/api_logs";
      final logsDir = Directory(logsPath);

      if (!await logsDir.exists()) {
        await logsDir.create(recursive: true);
      }

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final logFile = File("$logsPath/log_$timestamp.txt");

      final content = '''
      --- GEMINI API LOG ---
      TIMESTAMP: ${DateTime.now()}
      
      --- PROMPT ---
      $prompt
      
      --- RESPONSE ---
      $response
      ----------------------
      ''';

      await logFile.writeAsString(content);
    } catch (e) {
      debugPrint("Error writing log file: $e");
    }
  }
}
