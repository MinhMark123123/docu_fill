// Import your domain/JSON models (TemplateConfig, TemplateField)
import 'package:docu_fill/data/src/data_source/template_local_data_source.dart';
import 'package:docu_fill/data/src/entities/template_config_model.dart';
import 'package:docu_fill/data/src/repositories/template/template_repository.dart';
import 'package:docu_fill/data/src/template_config.dart';

class TemplateRepositoryImpl implements TemplateRepository {
  final TemplateLocalDataSource localDataSource;

  TemplateRepositoryImpl({required this.localDataSource});

  @override
  Future<List<TemplateConfig>> getAllTemplates() async {
    final models = await localDataSource.getAllTemplates();
    return models.map((model) => model.toDomain()).toList();
  }

  @override
  Future<TemplateConfig?> getTemplateByName(String name) async {
    final model = await localDataSource.getTemplateByName(name);
    return model?.toDomain();
  }

  @override
  Future<void> saveTemplate(TemplateConfig template) async {
    final model = TemplateConfigModel.fromDomain(template);

    await localDataSource.saveTemplate(model);
  }

  @override
  Future<void> deleteTemplateByName(String name) async {
    await localDataSource.deleteTemplateByName(name);
  }

  @override
  Stream<List<TemplateConfig>> watchAllTemplates() {
    final dataSourceImpl =
        localDataSource as TemplateLocalDataSourceImpl; // Cast if needed
    return dataSourceImpl.watchAllTemplates().map(
      (models) => models.map((model) => model.toDomain()).toList(),
    );
  }

  @override
  Stream<TemplateConfig?> watchTemplateByName(String name) {
    final dataSourceImpl =
        localDataSource as TemplateLocalDataSourceImpl; // Cast if needed
    return dataSourceImpl
        .watchTemplateByName(name)
        .map((model) => model?.toDomain());
  }

  @override
  Future<TemplateConfig?> getTemplateById(int id) async {
    final model = await localDataSource.getTemplateById(id);
    return model?.toDomain();
  }
}
