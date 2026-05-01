import 'dart:io';
import 'package:design/ui.dart';
import 'package:docu_fill/features/src/log_history/view_model/log_history_view_model.dart';
import 'package:flutter/material.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class LogHistoryItem extends StatelessWidget {
  final FileSystemEntity log;
  const LogHistoryItem({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final viewModel = getViewModel<LogHistoryViewModel>();
    final fileName = log.path.split('/').last;
    final fileSize = (log as File).lengthSync();

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: Dimens.radii.borderMedium(),
      ),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.description)),
        title: Text(fileName),
        subtitle: Text("Size: $fileSize bytes"),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.grey),
          onPressed: () => viewModel.deleteLog(log),
        ),
        onTap: () => viewModel.navigateToDetail(context, log),
      ),
    );
  }
}
