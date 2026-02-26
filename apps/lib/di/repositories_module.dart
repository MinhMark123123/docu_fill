import 'package:docu_fill/data/data.dart';
import 'package:docu_fill/data/src/services/template_service.dart';
import 'package:isar_community/isar.dart';

import 'app_get_it.dart';

void setupRepositoriesModule() {
  sl.registerSingleton<Isar>(IsarDatabase.instance.isar);
  // Register Template Data Source & Repository
  sl.registerLazySingleton<TemplateLocalDataSource>(
    () => TemplateLocalDataSourceImpl(inject()),
  );
  sl.registerLazySingleton<TemplateRepository>(
    () => TemplateRepositoryImpl(localDataSource: inject()),
  );
  sl.registerLazySingleton<TemplateService>(
    () => TemplateService(templateRepository: inject()),
  );
}
