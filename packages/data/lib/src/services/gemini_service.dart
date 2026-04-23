import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:data/data.dart';
import 'package:data/src/repositories/settings/settings_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

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
