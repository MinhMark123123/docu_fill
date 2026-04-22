import 'package:docu_fill/const/const.dart';
import 'package:docu_fill/core/core.dart';
import 'package:docu_fill/ui/ui.dart';
import 'package:docu_fill/utils/utils.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

import 'view_model/log_detail_view_model.dart';

class LogDetailPage extends BaseView<LogDetailViewModel> {
  final String fileName;
  const LogDetailPage({super.key, required this.fileName});

  @override
  void awake(WrapperContext wrapperContext, LogDetailViewModel viewModel) {
    super.awake(wrapperContext, viewModel);
    viewModel.loadLogDetail(fileName);
  }

  @override
  Widget build(BuildContext context, LogDetailViewModel viewModel) {
    return Scaffold(
      backgroundColor: context.appColors?.containerBackground,
      appBar: AppBar(
        title: Text(AppLang.labelsLogDetails.tr()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          StreamDataConsumer(
            streamData: viewModel.content,
            builder: (context, String content) {
              return IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: content));
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text("Copied to clipboard")));
                },
              );
            },
          ),
        ],
      ),
      body: StreamDataConsumer(
        streamData: viewModel.content,
        builder: (context, String content) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(Dimens.size24),
            child: SelectionArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _buildSectionTitle(context, fileName, Icons.file_present),
                  const SizedBox(height: 16),
                  Card(
                    color: context.colorScheme.surfaceVariant.withOpacity(0.3),
                    child: Padding(
                      padding: EdgeInsets.all(Dimens.size16),
                      child: Text(
                        content,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: context.colorScheme.primary),
        const SizedBox(width: 12),
        Text(
          title,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
