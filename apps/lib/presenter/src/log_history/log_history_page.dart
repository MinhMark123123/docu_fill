import 'dart:io';

import 'package:docu_fill/const/const.dart';
import 'package:docu_fill/core/core.dart';
import 'package:docu_fill/ui/ui.dart';
import 'package:docu_fill/utils/src/context_extension.dart';
import 'package:docu_fill/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

import 'view_model/log_history_view_model.dart';

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
            onPressed: () => _confirmDeleteAll(context, viewModel),
          ),
        ],
      ),
      body: StreamDataConsumer(
        streamData: viewModel.logs,
        builder: (context, List<FileSystemEntity> logs) {
          if (logs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_toggle_off,
                    size: 64,
                    color: context.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLang.messagesNoLogsFound.tr(),
                    style: context.textTheme.titleMedium?.copyWith(
                      color: context.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(Dimens.size16),
            itemCount: logs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final log = logs[index];
              final fileName = log.path.split('/').last;
              return Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: Dimens.radii.borderMedium(),
                ),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.description)),
                  title: Text(fileName),
                  subtitle: Text("Size: ${(log as File).lengthSync()} bytes"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.grey),
                    onPressed: () => viewModel.deleteLog(log),
                  ),
                  onTap: () => viewModel.navigateToDetail(context, log),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDeleteAll(BuildContext context, LogHistoryViewModel viewModel) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppLang.actionsDelete.tr()),
            content: Text(AppLang.messagesConfirmDeleteAllLogs.tr()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLang.actionsCancel.tr()),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colorScheme.error,
                  foregroundColor: context.colorScheme.onError,
                ),
                onPressed: () {
                  viewModel.deleteAllLogs();
                  Navigator.pop(context);
                },
                child: Text(AppLang.actionsDelete.tr()),
              ),
            ],
          ),
    );
  }
}
