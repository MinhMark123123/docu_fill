import 'package:data/src/entities/export_history_model.dart';
import 'package:isar_community/isar.dart';

abstract class ExportHistoryLocalDataSource {
  Future<Id> saveHistory(ExportHistoryModel history);
  Future<ExportHistoryModel?> getHistoryById(int id);
  Future<List<ExportHistoryModel>> getRecentHistories({int limit = 50});
  Future<List<ExportHistoryModel>> getHistoriesBetween({
    required DateTime start,
    required DateTime end,
  });
  Stream<List<ExportHistoryModel>> watchRecentHistories({int limit = 50});
}

class ExportHistoryLocalDataSourceImpl implements ExportHistoryLocalDataSource {
  final Isar _isar;

  ExportHistoryLocalDataSourceImpl(this._isar);

  @override
  Future<Id> saveHistory(ExportHistoryModel history) async {
    return await _isar.writeTxn(() async {
      return await _isar.exportHistoryModels.put(history);
    });
  }

  @override
  Future<ExportHistoryModel?> getHistoryById(int id) async {
    return await _isar.exportHistoryModels.filter().idEqualTo(id).findFirst();
  }

  @override
  Future<List<ExportHistoryModel>> getRecentHistories({int limit = 50}) async {
    return await _isar.exportHistoryModels
        .where()
        .sortByCreatedAtDesc()
        .limit(limit)
        .findAll();
  }

  @override
  Future<List<ExportHistoryModel>> getHistoriesBetween({
    required DateTime start,
    required DateTime end,
  }) async {
    return await _isar.exportHistoryModels
        .filter()
        .createdAtBetween(start, end)
        .sortByCreatedAtDesc()
        .findAll();
  }

  @override
  Stream<List<ExportHistoryModel>> watchRecentHistories({int limit = 50}) {
    return _isar.exportHistoryModels
        .where()
        .sortByCreatedAtDesc()
        .limit(limit)
        .watch(fireImmediately: true);
  }
}
