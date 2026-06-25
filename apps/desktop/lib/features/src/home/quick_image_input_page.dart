import 'package:data/data.dart';
import 'package:design/ui.dart';
import 'package:docu_fill/core/src/base_view.dart';
import 'package:docu_fill/features/src/home/components/quick_image_input_grid.dart';
import 'package:docu_fill/features/src/home/view_model/quick_image_input_view_model.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class QuickImageInputPage extends BaseView<QuickImageInputViewModel> {
  final List<TemplateField> imageFields;
  final Map<String, String?> currentValues;

  const QuickImageInputPage({
    super.key,
    required this.imageFields,
    required this.currentValues,
  });

  @override
  void awake(
    WrapperContext wrapperContext,
    QuickImageInputViewModel viewModel,
  ) {
    super.awake(wrapperContext, viewModel);
    viewModel.initialize(
      imageFields: imageFields,
      currentValues: currentValues,
    );
  }

  @override
  Widget build(BuildContext context, QuickImageInputViewModel viewModel) {
    return StreamDataConsumer<List<TemplateField>>(
      streamData: viewModel.imageFields,
      builder: (context, fields) {
        return StreamDataConsumer<Map<String, String?>>(
          streamData: viewModel.paths,
          builder: (context, paths) {
            final mappedCount =
                paths.values
                    .where((path) => path != null && path.isNotEmpty)
                    .length;
            final totalCount = fields.length;

            return Scaffold(
              backgroundColor:
                  context.appColors?.containerBackground ??
                  context.colorScheme.surface,
              appBar: _buildAppBar(context, mappedCount, totalCount),
              body: SafeArea(
                child: Column(
                  children: [
                    _TopControlsBar(viewModel: viewModel),
                    Expanded(
                      child: QuickImageInputGrid(
                        fields: fields,
                        paths: paths,
                        viewModel: viewModel,
                      ),
                    ),
                    _BottomConfirmBar(paths: paths),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    int mappedCount,
    int totalCount,
  ) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLang.labelsQuickImageInputTitle.tr(),
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            AppLang.labelsQuickImageInputSubtitle.tr(),
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: context.colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.colorScheme.primary.withOpacity(0.4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.photo_library_rounded,
                size: 14,
                color: context.colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                AppLang.labelsMappedImagesCount.tr(
                  args: [mappedCount.toString(), totalCount.toString()],
                ),
                style: context.textTheme.labelMedium?.copyWith(
                  color: context.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TopControlsBar extends StatelessWidget {
  final QuickImageInputViewModel viewModel;

  const _TopControlsBar({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: context.colorScheme.outlineVariant.withOpacity(0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          FilledButton.icon(
            onPressed: () => viewModel.pickMultipleImages(),
            icon: const Icon(Icons.add_photo_alternate_rounded, size: 18),
            label: Text(AppLang.actionsSelectMultipleImages.tr()),
            style: FilledButton.styleFrom(
              backgroundColor: context.colorScheme.primary,
              foregroundColor: context.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: () => viewModel.clearAllImages(),
            icon: const Icon(Icons.delete_sweep_outlined, size: 18),
            label: Text(AppLang.actionsClearAllImages.tr()),
            style: OutlinedButton.styleFrom(
              foregroundColor: context.colorScheme.error,
              side: BorderSide(
                color: context.colorScheme.error.withOpacity(0.5),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const Spacer(),
          Text(
            AppLang.labelsQuickImageInputTip.tr(),
            style: context.textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomConfirmBar extends StatelessWidget {
  final Map<String, String?> paths;

  const _BottomConfirmBar({required this.paths});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: context.colorScheme.outlineVariant.withOpacity(0.5),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(AppLang.actionsCancel.tr()),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, paths),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colorScheme.primary,
              foregroundColor: context.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: Text(AppLang.actionsConfirmAndApply.tr()),
          ),
        ],
      ),
    );
  }
}
