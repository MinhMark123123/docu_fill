import 'package:docu_fill/data/src/template_field.dart';
import 'package:isar_community/isar.dart';

part 'template_field_model.g.dart'; // Will be generated

@embedded // Marks this as an object to be embedded within another collection
class TemplateFieldModel {
  // No Id field for embedded objects

  late String key;
  late String label;
  late String type;
  late bool required;

  // 'default' is a keyword, Isar handles field names
  String? defaultValue;

  // directly
  List<String>? options;

  String? additionalInfo;

  // Default constructor for Isar
  TemplateFieldModel({
    this.key = '', // Provide defaults or make them required
    this.label = '',
    this.type = '',
    this.required = false,
    this.defaultValue,
    this.options,
    this.additionalInfo,
  });

  // It's good practice to have a way to create this from your domain/JSON model
  factory TemplateFieldModel.fromDomain(TemplateField domainField) {
    return TemplateFieldModel(
      key: domainField.key,
      label: domainField.label,
      type: domainField.type.value,
      required: domainField.required,
      defaultValue: domainField.defaultValue,
      options: domainField.options,
      additionalInfo: domainField.additionalInfo,
    );
  }

  // And to convert back to your domain/JSON model
  TemplateField toDomain() {
    return TemplateField(
      key: key,
      label: label,
      type: FieldType.fromValue(type),
      required: required,
      defaultValue: defaultValue,
      options: options,
      additionalInfo: additionalInfo,
    );
  }
}
