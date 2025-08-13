import 'package:json_annotation/json_annotation.dart';

// This line is needed to connect this file with the generated file.
part 'template_field.g.dart'; // Ensure this matches your file name

@JsonSerializable(explicitToJson: true, createToJson: true, createFactory: true)
class TemplateField {
  final String key;
  final String label;
  final FieldType type;
  final bool required;

  // Use @JsonKey to map Dart field name 'defaultValue' to JSON key 'default'
  @JsonKey(name: 'default')
  final String? defaultValue;

  final List<String>? options;

  final String? additionalInfo;

  TemplateField({
    required this.key,
    required this.label,
    required this.type,
    required this.required,
    this.defaultValue,
    this.options,
    this.additionalInfo,
  });

  factory TemplateField.fromJson(Map<String, dynamic> json) =>
      _$TemplateFieldFromJson(json);

  Map<String, dynamic> toJson() => _$TemplateFieldToJson(this);
}

enum FieldType {
  @JsonValue("text")
  text("text"),
  @JsonValue("datetime")
  datetime("datetime"),
  @JsonValue("selection")
  selection("selection"),
  @JsonValue("image")
  image("image");

  final String value;

  const FieldType(this.value);

  static FieldType fromValue(String? value) {
    return FieldType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FieldType.text,
    );
  }

  String label() {
    switch (this) {
      case FieldType.text:
        return "Text";
      case FieldType.datetime:
        return "Date Time";
      case FieldType.selection:
        return "Selection";
      case FieldType.image:
        return "Image";
    }
  }

  bool get isSelection => this == FieldType.selection;
  bool get isDateTime => this == FieldType.datetime;
  bool get isImage => this == FieldType.image;
}
