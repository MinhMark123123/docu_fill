import 'package:docu_fill/data/src/entities/template_config_model.dart';
import 'package:isar/isar.dart';

abstract class TemplateLocalDataSource {
  Future<List<TemplateConfigModel>> getAllTemplates();
  Future<TemplateConfigModel?> getTemplateByName(String name);
  Future<Id> saveTemplate(TemplateConfigModel template); // Returns ID
  Future<bool> deleteTemplate(Id templateId);
  Future<bool> deleteTemplateByName(String name);
}

class TemplateLocalDataSourceImpl implements TemplateLocalDataSource {
  final Isar _isar;

  TemplateLocalDataSourceImpl(this._isar);

  @override
  Future<List<TemplateConfigModel>> getAllTemplates() async {
    return await _isar.templateConfigModels.where().findAll();
  }

  @override
  Future<TemplateConfigModel?> getTemplateByName(String name) async {
    return await _isar.templateConfigModels
        .filter()
        .templateNameEqualTo(name)
        .findFirst();
  }

  @override
  Future<Id> saveTemplate(TemplateConfigModel template) async {
    return await _isar.writeTxn(() async {
      return await _isar.templateConfigModels.put(template);
    });
  }

  @override
  Future<bool> deleteTemplate(Id templateId) async {
    return await _isar.writeTxn(() async {
      return await _isar.templateConfigModels.delete(templateId);
    });
  }

  @override
  Future<bool> deleteTemplateByName(String name) async {
    return await _isar.writeTxn(() async {
      final template = await getTemplateByName(name);
      if (template != null) {
        return await _isar.templateConfigModels.delete(template.id);
      }
      return false;
    });
  }

  Stream<List<TemplateConfigModel>> watchAllTemplates() {
    return _isar.templateConfigModels.where().watch(fireImmediately: true);
  }

  Stream<TemplateConfigModel?> watchTemplateByName(String name) {
    return _isar.templateConfigModels
        .filter()
        .templateNameEqualTo(name)
        .watch(fireImmediately: true)
        .map((results) => results.isNotEmpty ? results.first : null);
  }
}
