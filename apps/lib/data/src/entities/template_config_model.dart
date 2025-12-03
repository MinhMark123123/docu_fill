import 'package:docu_fill/data/src/template_config.dart';
import 'package:isar_community/isar.dart';

import 'template_field_model.dart'; // Import the embedded model

part 'template_config_model.g.dart'; // Will be generated

@collection
class TemplateConfigModel {
  Id id = Isar.autoIncrement;

  @Index(
    unique: true,
    replace: true,
  ) // Ensure templateName is unique and replaces on conflict
  late String templateName;
  late String pathTemplate;

  late String version;

  // List of embedded objects
  List<TemplateFieldModel> fields = [];

  // Default constructor for Isar
  TemplateConfigModel({
    this.id = Isar.autoIncrement,
    this.templateName = '',
    this.pathTemplate = '',
    this.version = '',
    this.fields = const [],
  });

  // It's good practice to have a way to create this from your domain/JSON model
  factory TemplateConfigModel.fromDomain(TemplateConfig domainConfig) {
    return TemplateConfigModel(
      // id will be handled by Isar or set if updating an existing one
      templateName: domainConfig.templateName,
      pathTemplate: domainConfig.pathTemplate,
      version: domainConfig.version,
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
    )..id = id;
  }
}
