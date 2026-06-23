// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TemplateConfig _$TemplateConfigFromJson(Map<String, dynamic> json) =>
    TemplateConfig(
      id: (json['id'] as num?)?.toInt() ?? 0,
      templateName: json['template_name'] as String,
      pathTemplate: json['pathTemplate'] as String,
      version: json['version'] as String,
      fields:
          (json['fields'] as List<dynamic>)
              .map((e) => TemplateField.fromJson(e as Map<String, dynamic>))
              .toList(),
      isDeleted: json['isDeleted'] as bool? ?? false,
      deletedAt:
          json['deletedAt'] == null
              ? null
              : DateTime.parse(json['deletedAt'] as String),
      createdAt:
          json['createdAt'] == null
              ? null
              : DateTime.parse(json['createdAt'] as String),
      updatedAt:
          json['updatedAt'] == null
              ? null
              : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$TemplateConfigToJson(TemplateConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'template_name': instance.templateName,
      'pathTemplate': instance.pathTemplate,
      'version': instance.version,
      'fields': instance.fields.map((e) => e.toJson()).toList(),
      'isDeleted': instance.isDeleted,
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
