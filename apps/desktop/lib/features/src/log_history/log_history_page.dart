import 'dart:io';

import 'package:design/ui.dart';
import 'package:docu_fill/core/src/base_view.dart';
import 'package:docu_fill/core/src/events.dart';
import 'package:docu_fill/features/src/log_history/components/log_history_empty.dart';
import 'package:docu_fill/features/src/log_history/components/log_history_item.dart';
import 'package:docu_fill/features/src/log_history/view_model/log_history_view_model.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class LogHistoryPage extends BaseView<LogHistoryViewModel> {
  const LogHistoryPage({super.key});

  @override
  Widget build(BuildContext context, LogHistoryViewModel viewModel) {
    return Scaffold(
      backgroundColor: context.appColors?.containerBackground,
      appBar: AppBar(
        title: Text(AppLang.labelsLogHistory.tr()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => viewModel.loadLogs(),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.red),
            onPressed: () => viewModel.confirmDeleteAll(context),
          ),
        ],
      ),
      body: StreamDataConsumer(
        streamData: viewModel.logs,
        builder: (context, List<FileSystemEntity> logs) {
          if (logs.isEmpty) return const LogHistoryEmpty();

          return ListView.separated(
            padding: EdgeInsets.all(Dimens.size16),
            itemCount: logs.length,
            separatorBuilder:
                (context, index) => Dimens.spacing.vertical(Dimens.size8),
            itemBuilder: (context, index) => LogHistoryItem(log: logs[index]),
          );
        },
      ),
    );
  }
}
