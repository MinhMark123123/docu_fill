import 'package:isar_community/isar.dart';

part 'app_settings_model.g.dart';

@collection
class AppSettingsModel {
  Id id = Isar.autoIncrement;

  String? geminiApiKey;
  String? geminiModel;
  String? languageCode;
  String? countryCode;

  // You can add more settings here in the future
}

