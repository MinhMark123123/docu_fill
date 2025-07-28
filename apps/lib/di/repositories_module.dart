import 'package:docu_fill/data/data.dart';
import 'package:isar/isar.dart';

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
}
