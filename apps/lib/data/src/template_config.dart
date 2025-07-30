import 'package:docu_fill/data/src/template_field.dart';
import 'package:json_annotation/json_annotation.dart';

// This line is needed to connect this file with the generated file.
part 'template_config.g.dart'; // Ensure this matches your file name

@JsonSerializable(
  explicitToJson: true, // Recommended for nested objects
  createToJson: true, // Generate toJson method
  createFactory: true, // Generate fromJson factory
)
class TemplateConfig {
  late int id;
  @JsonKey(name: 'template_name')
  final String templateName;
  final String pathTemplate;
  final String version;
  final List<TemplateField> fields;

  TemplateConfig({
    required this.templateName,
    required this.pathTemplate,
    required this.version,
    required this.fields,
  });

  // Factory constructor for creating a new EmployeeTemplate instance from a map.
  factory TemplateConfig.fromJson(Map<String, dynamic> json) =>
      _$TemplateConfigFromJson(json);

  // Converts this EmployeeTemplate instance to a map.
  Map<String, dynamic> toJson() => _$TemplateConfigToJson(this);

  factory TemplateConfig.none() => TemplateConfig(templateName: '',
      pathTemplate: '', version: '', fields: []);
}
