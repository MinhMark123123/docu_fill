import 'package:data/src/export_history.dart';

abstract class ExportHistoryRepository {
  Future<void> saveHistory(ExportHistory history);
  Future<ExportHistory?> getHistoryById(int id);
  Future<List<ExportHistory>> getRecentHistories({int limit = 50});
  Future<List<ExportHistory>> getHistoriesBetween({
    required DateTime start,
    required DateTime end,
  });
  Stream<List<ExportHistory>> watchRecentHistories({int limit = 50});
}
