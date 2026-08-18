import 'dart:async';

import 'package:data/data.dart';
import 'package:docu_fill/core/core.dart';
import 'package:maac_mvvm_annotation/maac_mvvm_annotation.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

part 'dashboard_view_model.g.dart';

@BindableViewModel()
class DashboardViewModel extends BaseViewModel {
  final ExportHistoryRepository _exportHistoryRepository;

  DashboardViewModel({
    required ExportHistoryRepository exportHistoryRepository,
  }) : _exportHistoryRepository = exportHistoryRepository;

  @Bind()
  late final _selectedYear = DateTime.now().year.mtd(this);
  @Bind()
  late final _selectedMonth = DateTime.now().month.mtd(this);

  @Bind()
  late final _totalExportedFiles = 0.mtd(this);
  @Bind()
  late final _totalExportActions = 0.mtd(this);
  @Bind()
  late final _successCount = 0.mtd(this);
  @Bind()
  late final _failedCount = 0.mtd(this);
  @Bind()
  late final _partialSuccessCount = 0.mtd(this);
  @Bind()
  late final _successRate = 0.0.mtd(this);
  @Bind()
  late final _topTemplates = List<MapEntry<String, int>>.empty().mtd(this);
  @Bind()
  late final _dailyExports = <int, int>{}.mtd(this);

  StreamSubscription? _historySubscription;

  @override
  void onInitState() {
    super.onInitState();
    // Whenever export history collection changes in Isar, refresh stats
    _historySubscription = _exportHistoryRepository.watchRecentHistories().listen((_) {
      loadStats();
    });
    loadStats();
  }

  @override
  void onDispose() {
    _historySubscription?.cancel();
    super.onDispose();
  }

  void updatePeriod(int year, int month) {
    _selectedYear.postValue(year);
    _selectedMonth.postValue(month);
    loadStats();
  }

  int get daysInMonth {
    final y = _selectedYear.data;
    final m = _selectedMonth.data;
    return DateTime(y, m + 1, 0).day;
  }

  Future<void> loadStats() async {
    final year = _selectedYear.data;
    final month = _selectedMonth.data;
    final list = await _exportHistoryRepository.getHistoriesByMonth(year, month);

    int totalFiles = 0;
    int totalActions = list.length;
    int success = 0;
    int failed = 0;
    int partial = 0;

    final dayMap = <int, int>{};
    final templateCount = <String, int>{};

    for (final history in list) {
      totalFiles += history.documentCount;
      if (history.status == ExportHistoryStatus.success) {
        success++;
      } else if (history.status == ExportHistoryStatus.failed) {
        failed++;
      } else if (history.status == ExportHistoryStatus.partialSuccess) {
        partial++;
      }

      final day = history.createdAt.day;
      dayMap[day] = (dayMap[day] ?? 0) + history.documentCount;

      for (final template in history.templateSnapshots) {
        templateCount[template.templateName] = (templateCount[template.templateName] ?? 0) + 1;
      }
    }

    _totalExportedFiles.postValue(totalFiles);
    _totalExportActions.postValue(totalActions);
    _successCount.postValue(success);
    _failedCount.postValue(failed);
    _partialSuccessCount.postValue(partial);

    final rate = totalActions > 0 ? ((success + partial) / totalActions) * 100 : 0.0;
    _successRate.postValue(rate);

    final sortedTemplates = templateCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    _topTemplates.postValue(sortedTemplates);

    _dailyExports.postValue(dayMap);
  }
}
