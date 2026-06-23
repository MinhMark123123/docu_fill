import 'package:data/src/template_config.dart';
import 'package:isar_community/isar.dart';

import 'template_field_model.dart'; // Import the embedded model

part 'template_config_model.g.dart'; // Will be generated

@collection
class TemplateConfigModel {
  Id id = Isar.autoIncrement;

  late String templateName;
  late String pathTemplate;

  late String version;
  bool? isDeleted;
  DateTime? deletedAt;
  DateTime? createdAt;
  DateTime? updatedAt;

  // List of embedded objects
  List<TemplateFieldModel> fields = [];

  // Default constructor for Isar
  TemplateConfigModel({
    this.id = Isar.autoIncrement,
    this.templateName = '',
    this.pathTemplate = '',
    this.version = '',
    this.isDeleted = false,
    this.deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.fields = const [],
  });

  // It's good practice to have a way to create this from your domain/JSON model
  factory TemplateConfigModel.fromDomain(TemplateConfig domainConfig) {
    return TemplateConfigModel(
      // id will be handled by Isar or set if updating an existing one
      templateName: domainConfig.templateName,
      pathTemplate: domainConfig.pathTemplate,
      version: domainConfig.version,
      isDeleted: domainConfig.isDeleted,
      deletedAt: domainConfig.deletedAt,
      createdAt: domainConfig.createdAt,
      updatedAt: domainConfig.updatedAt,
      fields:
          domainConfig.fields
              .map((field) => TemplateFieldModel.fromDomain(field))
              .toList(),
    );
  }
  // It's good practice to have a way to create this from your domain/JSON model
  factory TemplateConfigModel.fromDomainId(
    int id,
    TemplateConfig domainConfig,
  ) {
    return TemplateConfigModel(
      id: id,
      // id will be handled by Isar or set if updating an existing one
      templateName: domainConfig.templateName,
      pathTemplate: domainConfig.pathTemplate,
      version: domainConfig.version,
      isDeleted: domainConfig.isDeleted,
      deletedAt: domainConfig.deletedAt,
      createdAt: domainConfig.createdAt,
      updatedAt: domainConfig.updatedAt,
      fields:
          domainConfig.fields
              .map((field) => TemplateFieldModel.fromDomain(field))
              .toList(),
    );
  }

  // And to convert back to your domain/JSON model
  TemplateConfig toDomain() {
    return TemplateConfig(
      templateName: templateName,
      pathTemplate: pathTemplate,
      version: version,
      fields: fields.map((modelField) => modelField.toDomain()).toList(),
      isDeleted: isDeleted ?? false,
      deletedAt: deletedAt,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    )..id = id;
  }

  TemplateConfigModel copyWith({
    Id? id,
    String? templateName,
    String? pathTemplate,
    String? version,
    bool? isDeleted,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<TemplateFieldModel>? fields,
  }) {
    return TemplateConfigModel(
      id: id ?? this.id,
      templateName: templateName ?? this.templateName,
      pathTemplate: pathTemplate ?? this.pathTemplate,
      version: version ?? this.version,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fields: fields ?? this.fields,
    );
  }
}
