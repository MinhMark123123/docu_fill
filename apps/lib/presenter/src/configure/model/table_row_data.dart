// Data model for a table row (optional, but good for organization)
import 'package:docu_fill/data/src/template_field.dart';

class TableRowData {
  String fieldKey;
  String? fieldName;
  FieldType inputType;
  List<String>? options;
  bool isRequired;
  String? additionalInfo;
  String? defaultValue;

  TableRowData({
    required this.fieldKey,
    this.inputType = FieldType.text,
    this.fieldName,
    this.options,
    this.isRequired = false,
    this.additionalInfo,
    this.defaultValue,
  });

  TableRowData copyWith({
    String? fieldKey,
    String? fieldName,
    FieldType? inputType,
    List<String>? options,
    bool? isRequired,
    String? additionalInfo,
    String? defaultValue,
  }) {
    return TableRowData(
      fieldKey: fieldKey ?? this.fieldKey,
      fieldName: fieldName ?? this.fieldName,
      inputType: inputType ?? this.inputType,
      options: options ?? this.options,
      isRequired: isRequired ?? this.isRequired,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      defaultValue: defaultValue ?? this.defaultValue,
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
    );
  }
}
