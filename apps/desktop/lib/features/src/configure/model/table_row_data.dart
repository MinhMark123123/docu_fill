// Data model for a table row (optional, but good for organization)
import 'package:data/data.dart';

class TableRowData {
  String fieldKey;
  String? fieldName;
  FieldType inputType;
  List<String>? options;
  bool isRequired;
  String? additionalInfo;
  String? defaultValue;
  String? section;
  String? description;

  TableRowData({
    required this.fieldKey,
    this.inputType = FieldType.text,
    this.fieldName,
    this.options,
    this.isRequired = false,
    this.additionalInfo,
    this.defaultValue,
    this.section,
    this.description,
  });

  factory TableRowData.fromTemplateField(TemplateField field) {
    return TableRowData(
      fieldKey: field.key,
      fieldName: field.label,
      inputType: field.type,
      options: field.options,
      isRequired: field.required,
      additionalInfo: field.additionalInfo,
      defaultValue: field.defaultValue,
      section: field.section,
      description: field.description,
    );
  }

  TableRowData copyWith({
    String? fieldKey,
    String? fieldName,
    FieldType? inputType,
    List<String>? options,
    bool? isRequired,
    String? additionalInfo,
    String? defaultValue,
    String? section,
    String? description,
  }) {
    return TableRowData(
      fieldKey: fieldKey ?? this.fieldKey,
      fieldName: fieldName ?? this.fieldName,
      inputType: inputType ?? this.inputType,
      options: options ?? this.options,
      isRequired: isRequired ?? this.isRequired,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      defaultValue: defaultValue ?? this.defaultValue,
      section: section ?? this.section,
      description: description ?? this.description,
    );
  }

  TableRowData removeOptions() {
    return TableRowData(
      fieldKey: fieldKey,
      fieldName: fieldName,
      inputType: inputType,
      isRequired: isRequired,
      additionalInfo: additionalInfo,
      defaultValue: defaultValue,
      section: section,
      description: description,
    );
  }

  TemplateField toTemplateField() {
    return TemplateField(
      key: fieldKey,
      label: fieldName ?? "",
      type: inputType,
      options: options,
      required: isRequired,
      additionalInfo: additionalInfo,
      defaultValue: defaultValue,
      section: section,
      description: description,
    );
  }
}
