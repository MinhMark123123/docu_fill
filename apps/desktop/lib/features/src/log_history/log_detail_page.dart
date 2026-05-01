import 'package:design/ui.dart';
import 'package:docu_fill/core/src/base_view.dart';
import 'package:docu_fill/features/src/log_history/components/log_detail_content.dart';
import 'package:docu_fill/features/src/log_history/view_model/log_detail_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localization/localization.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Copied to clipboard")),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: StreamDataConsumer(
        streamData: viewModel.content,
        builder: (context, String content) {
          return LogDetailContent(fileName: fileName, content: content);
        },
      ),
    );
  }
}
