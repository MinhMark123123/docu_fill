// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template_field.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TemplateField _$TemplateFieldFromJson(Map<String, dynamic> json) =>
    TemplateField(
      key: json['key'] as String,
      label: json['label'] as String,
      type: $enumDecode(_$FieldTypeEnumMap, json['type']),
      required: json['required'] as bool,
      defaultValue: json['default'] as String?,
      options:
          (json['options'] as List<dynamic>?)?.map((e) => e as String).toList(),
      additionalInfo: json['additionalInfo'] as String?,
    );

Map<String, dynamic> _$TemplateFieldToJson(TemplateField instance) =>
    <String, dynamic>{
      'key': instance.key,
      'label': instance.label,
      'type': _$FieldTypeEnumMap[instance.type]!,
      'required': instance.required,
      'default': instance.defaultValue,
      'options': instance.options,
      'additionalInfo': instance.additionalInfo,
    };

const _$FieldTypeEnumMap = {
  FieldType.text: 'text',
  FieldType.datetime: 'datetime',
  FieldType.selection: 'selection',
  FieldType.image: 'image',
};
