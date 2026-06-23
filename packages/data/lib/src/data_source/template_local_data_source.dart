import 'package:data/src/entities/template_config_model.dart';
import 'package:isar_community/isar.dart';

abstract class TemplateLocalDataSource {
  Future<List<TemplateConfigModel>> getAllTemplates();

  Future<TemplateConfigModel?> getTemplateById(int id);

  Future<TemplateConfigModel?> getTemplateByIdIncludingDeleted(int id);

  Future<TemplateConfigModel?> getTemplateByName(String name);

  Future<Id> saveTemplate(TemplateConfigModel template); // Returns ID
  Future<bool> deleteTemplate(Id templateId);

  Future<bool> softDeleteTemplate(Id templateId);

  Future<bool> deleteTemplateByName(String name);
}

class TemplateLocalDataSourceImpl implements TemplateLocalDataSource {
  final Isar _isar;

  TemplateLocalDataSourceImpl(this._isar);

  @override
  Future<List<TemplateConfigModel>> getAllTemplates() async {
    return await _isar.templateConfigModels
        .filter()
        .isDeletedEqualTo(false)
        .findAll();
  }

  @override
  Future<TemplateConfigModel?> getTemplateByName(String name) async {
    return await _isar.templateConfigModels
        .filter()
        .templateNameEqualTo(name)
        .isDeletedEqualTo(false)
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
  Future<bool> softDeleteTemplate(Id templateId) async {
    return await _isar.writeTxn(() async {
      final template = await getTemplateByIdIncludingDeleted(templateId);
      if (template == null) return false;
      template.isDeleted = true;
      template.deletedAt = DateTime.now();
      template.updatedAt = DateTime.now();
      await _isar.templateConfigModels.put(template);
      return true;
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
    return _isar.templateConfigModels
        .filter()
        .isDeletedEqualTo(false)
        .or()
        .isDeletedIsNull()
        .watch(fireImmediately: true);
  }

  Stream<TemplateConfigModel?> watchTemplateByName(String name) {
    return _isar.templateConfigModels
        .filter()
        .templateNameEqualTo(name)
        .isDeletedEqualTo(false)
        .watch(fireImmediately: true)
        .map((results) => results.isNotEmpty ? results.first : null);
  }

  @override
  Future<TemplateConfigModel?> getTemplateById(int id) async {
    return await _isar.templateConfigModels
        .filter()
        .idEqualTo(id)
        .isDeletedEqualTo(false)
        .findFirst();
  }

  @override
  Future<TemplateConfigModel?> getTemplateByIdIncludingDeleted(int id) async {
    return await _isar.templateConfigModels.filter().idEqualTo(id).findFirst();
  }
}
