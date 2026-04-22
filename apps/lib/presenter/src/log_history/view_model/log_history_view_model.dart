import 'dart:io';

import 'package:docu_fill/const/const.dart';
import 'package:docu_fill/core/core.dart';
import 'package:docu_fill/route/src/routes_path.dart';
import 'package:flutter/material.dart';
import 'package:maac_mvvm_annotation/maac_mvvm_annotation.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';
import 'package:path_provider/path_provider.dart';

part 'log_history_view_model.g.dart';

@BindableViewModel()
class LogHistoryViewModel extends BaseViewModel {
  @Bind()
  late final _logs = <FileSystemEntity>[].mtd(this);

  @override
  void onInitState() {
    super.onInitState();
    loadLogs();
  }

  Future<void> loadLogs() async {
    await loadingGuard(
      Future(() async {
        try {
          final directory = await getApplicationDocumentsDirectory();
          final logsPath = "${directory.path}/api_logs";
          final logsDir = Directory(logsPath);

          if (await logsDir.exists()) {
            final files = await logsDir.list().toList();
            // Sort by name descending (timestamp based names will put newest first)
            files.sort((a, b) => b.path.compareTo(a.path));
            _logs.postValue(files);
          } else {
            _logs.postValue([]);
          }
        } catch (e) {
          showSnackbar("Error loading logs: $e");
        }
      }),
    );
  }

  Future<void> deleteLog(FileSystemEntity log) async {
    try {
      await log.delete();
      await loadLogs();
      showSnackbar("Log deleted");
    } catch (e) {
      showSnackbar("Error deleting log: $e");
    }
  }

  Future<void> deleteAllLogs() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logsPath = "${directory.path}/api_logs";
      final logsDir = Directory(logsPath);

      if (await logsDir.exists()) {
        await logsDir.delete(recursive: true);
        await logsDir.create(recursive: true);
      }
      await loadLogs();
      showSnackbar("All logs deleted");
    } catch (e) {
      showSnackbar("Error deleting all logs: $e");
    }
  }

  void navigateToDetail(BuildContext context, FileSystemEntity log) {
    final fileName = log.path.split('/').last;
    final route = "${RoutesPath.setting}/${RoutesPath.logHistory}/${RoutesPath.logDetail}";
    navigatePage(route, queryParameters: {'fileName': fileName});
  }
}
