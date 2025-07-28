import 'package:json_annotation/json_annotation.dart';

// This line is needed to connect this file with the generated file.
part 'template_field.g.dart'; // Ensure this matches your file name

@JsonSerializable(explicitToJson: true, createToJson: true, createFactory: true)
class TemplateField {
  final String key;
  final String label;
  final FileType type;
  final bool required;

  // Use @JsonKey to map Dart field name 'defaultValue' to JSON key 'default'
  @JsonKey(name: 'default')
  final String? defaultValue;

  final List<String>? options;

  TemplateField({
    required this.key,
    required this.label,
    required this.type,
    required this.required,
    this.defaultValue,
    this.options,
  });

  factory TemplateField.fromJson(Map<String, dynamic> json) =>
      _$TemplateFieldFromJson(json);

  Map<String, dynamic> toJson() => _$TemplateFieldToJson(this);
}

enum FileType {
  @JsonValue("text")
  text("text"),
  @JsonValue("datetime")
  datetime("datetime"),
  @JsonValue("selection")
  selection("selection");

  final String value;

  const FileType(this.value);

  static FileType fromValue(String? value) {
    return FileType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FileType.text,
    );
  }
}
