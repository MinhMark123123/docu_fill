import 'package:data/data.dart';
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
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(inject()),
  );
  sl.registerLazySingleton<DataExtractionService>(
    () => DataExtractionService(),
  );
  sl.registerLazySingleton<GeminiService>(() => GeminiService(inject()));
}
