import 'dart:io';

import 'package:design/ui.dart';
import 'package:docu_fill/core/core.dart';
import 'package:docu_fill/features/src/home/view_model/ai_result_selector_view_model.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';
import 'package:path/path.dart' as p;

class AiResultSelectorDialog extends BaseView<AiResultSelectorViewModel> {
  const AiResultSelectorDialog({super.key});

  @override
  Widget build(BuildContext context, AiResultSelectorViewModel viewModel) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: Dimens.radii.borderLarge()),
      child: Container(
        width: 600,
        height: 500,
        padding: EdgeInsets.all(Dimens.size24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _DialogHeader(),
            Dimens.spacing.vertical(Dimens.size24),
            Expanded(child: _FilesList(viewModel: viewModel)),
          ],
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLang.messagesSelectFromAiResults.tr(),
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              AppLang.messagesReviewBeforeExport.tr(),
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }
}

class _FilesList extends StatelessWidget {
  final AiResultSelectorViewModel viewModel;

  const _FilesList({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return StreamDataConsumer(
      streamData: viewModel.isLoading,
      builder: (context, isLoading) {
        if (isLoading) return const Center(child: CircularProgressIndicator());

        return StreamDataConsumer(
          streamData: viewModel.files,
          builder: (context, files) {
            if (files.isEmpty) {
              return Center(child: Text(AppLang.messagesExtractNoText.tr()));
            }

            return ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                return _FileTile(file: file, viewModel: viewModel);
              },
            );
          },
        );
      },
    );
  }
}

class _FileTile extends StatelessWidget {
  final File file;
  final AiResultSelectorViewModel viewModel;

  const _FileTile({required this.file, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final fileName = p.basename(file.path);
    final date = file.lastModifiedSync();

    return ListTile(
      leading: const Icon(Icons.description_outlined),
      title: Text(fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(date.toString().substring(0, 19)),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, size: 20),
        onPressed: () => viewModel.deleteFile(file),
      ),
      onTap: () async {
        final data = await viewModel.selectFile(file);
        if (context.mounted) Navigator.of(context).pop(data);
      },
    );
  }
}
