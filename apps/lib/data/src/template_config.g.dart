// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TemplateConfig _$TemplateConfigFromJson(Map<String, dynamic> json) =>
    TemplateConfig(
      templateName: json['template_name'] as String,
      version: json['version'] as String,
      fields:
          (json['fields'] as List<dynamic>)
              .map((e) => TemplateField.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$TemplateConfigToJson(TemplateConfig instance) =>
    <String, dynamic>{
      'template_name': instance.templateName,
      'version': instance.version,
      'fields': instance.fields.map((e) => e.toJson()).toList(),
    };
