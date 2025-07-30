// Data model for a table row (optional, but good for organization)
import 'package:docu_fill/data/src/template_field.dart';

class TableRowData {
  final String fieldKey;
  final String? fieldName;
  final FieldType inputType;
  final String? options;
  final bool isRequired;

  TableRowData({
    required this.fieldKey,
    this.inputType = FieldType.text,
    this.fieldName,
    this.options,
    this.isRequired = false,
  });

  TableRowData copyWith({
    String? fieldKey,
    String? fieldName,
    FieldType? inputType,
    String? options,
    bool? isRequired,
  }) {
    return TableRowData(
      fieldKey: fieldKey ?? this.fieldKey,
      fieldName: fieldName ?? this.fieldName,
      inputType: inputType ?? this.inputType,
      options: options ?? this.options,
      isRequired: isRequired ?? this.isRequired,
    );
  }

  TableRowData removeOptions() {
    return TableRowData(
      fieldKey: fieldKey,
      fieldName: fieldName,
      inputType: inputType,
      isRequired: isRequired,
    );
  }

  TemplateField toTemplateField() {
    return TemplateField(
      key: fieldKey,
      label: fieldName ?? "",
      type: inputType,
      options: options?.split(","),
      required: isRequired,
    );
  }
}
