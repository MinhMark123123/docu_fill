import 'package:data/src/template_field.dart';
import 'package:json_annotation/json_annotation.dart';

// This line is needed to connect this file with the generated file.
part 'template_config.g.dart'; // Ensure this matches your file name

@JsonSerializable(
  explicitToJson: true, // Recommended for nested objects
  createToJson: true, // Generate toJson method
  createFactory: true, // Generate fromJson factory
)
class TemplateConfig {
  int id;
  @JsonKey(name: 'template_name')
  final String templateName;
  final String pathTemplate;
  final String version;
  final List<TemplateField> fields;
  @JsonKey(defaultValue: false)
  final bool isDeleted;
  final DateTime? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  TemplateConfig({
    this.id = 0,
    required this.templateName,
    required this.pathTemplate,
    required this.version,
    required this.fields,
    this.isDeleted = false,
    this.deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  TemplateConfig copyWith({
    int? id,
    String? templateName,
    String? pathTemplate,
    String? version,
    List<TemplateField>? fields,
    bool? isDeleted,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TemplateConfig(
      id: id ?? this.id,
      templateName: templateName ?? this.templateName,
      pathTemplate: pathTemplate ?? this.pathTemplate,
      version: version ?? this.version,
      fields: fields ?? this.fields,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Factory constructor for creating a new EmployeeTemplate instance from a map.
  factory TemplateConfig.fromJson(Map<String, dynamic> json) =>
      _$TemplateConfigFromJson(json);

  // Converts this EmployeeTemplate instance to a map.
  Map<String, dynamic> toJson() => _$TemplateConfigToJson(this);

  factory TemplateConfig.none() => TemplateConfig(
    templateName: '',
    pathTemplate: '',
    version: '',
    fields: [],
  );
}
