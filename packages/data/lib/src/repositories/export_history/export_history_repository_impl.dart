import 'package:data/src/data_source/export_history_local_data_source.dart';
import 'package:data/src/entities/export_history_model.dart';
import 'package:data/src/export_history.dart';
import 'package:data/src/repositories/export_history/export_history_repository.dart';

class ExportHistoryRepositoryImpl implements ExportHistoryRepository {
  final ExportHistoryLocalDataSource localDataSource;

  ExportHistoryRepositoryImpl({required this.localDataSource});

  @override
  Future<void> saveHistory(ExportHistory history) async {
    await localDataSource.saveHistory(ExportHistoryModel.fromDomain(history));
  }

  @override
  Future<ExportHistory?> getHistoryById(int id) async {
    final model = await localDataSource.getHistoryById(id);
    return model?.toDomain();
  }

  @override
  Future<List<ExportHistory>> getRecentHistories({int limit = 50}) async {
    final models = await localDataSource.getRecentHistories(limit: limit);
    return models.map((model) => model.toDomain()).toList();
  }

  @override
  Future<List<ExportHistory>> getHistoriesBetween({
    required DateTime start,
    required DateTime end,
  }) async {
    final models = await localDataSource.getHistoriesBetween(
      start: start,
      end: end,
    );
    return models.map((model) => model.toDomain()).toList();
  }

  @override
  Stream<List<ExportHistory>> watchRecentHistories({int limit = 50}) {
    return localDataSource
        .watchRecentHistories(limit: limit)
        .map((models) => models.map((model) => model.toDomain()).toList());
  }
}
