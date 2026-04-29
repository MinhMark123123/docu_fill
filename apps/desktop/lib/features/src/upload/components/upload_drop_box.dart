import 'package:core/core.dart';
import 'package:design/ui.dart';
import 'package:docu_fill/features/src/upload/view_model/upload_view_model.dart';
import 'package:docu_fill/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class UploadDropBox extends StatelessWidget {
  const UploadDropBox({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = getViewModel<UploadViewModel>();
    return GestureDetector(
      onTap: () => viewModel.pickFile(),
      child: Container(
        width: double.infinity,
        height: Dimens.size232 * 1.2,
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: Dimens.radii.borderLarge(),
          border: Border.all(
            color: context.colorScheme.primary.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: DashedBorderContainer(
          strokeWidth: 2,
          dashWidth: 10,
          borderColor: context.colorScheme.primary.withOpacity(0.5),
          borderRadius: Dimens.radii.borderLarge(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: Dimens.size64,
                color: context.colorScheme.primary,
              ),
              Dimens.spacing.vertical(Dimens.size16),
              Text(
                AppLang.messagesDragAndDropDocx.tr(),
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Dimens.spacing.vertical(Dimens.size8),
              Text(
                AppLang.actionsBrowseFiles.tr(),
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              Dimens.spacing.vertical(Dimens.size24),
              const _FilePickedStatus(),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilePickedStatus extends StatelessWidget {
  const _FilePickedStatus();

  @override
  Widget build(BuildContext context) {
    final viewModel = getViewModel<UploadViewModel>();
    return StreamDataConsumer(
      streamData: viewModel.filePicked,
      builder: (context, data) {
        return AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child:
              data.path == null
                  ? const SizedBox.shrink()
                  : Padding(
                    padding: EdgeInsets.only(bottom: Dimens.size34),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: Dimens.size16,
                      children: [
                        Assets.images.png.imageDocument.image(width: Dimens.size30),
                        Text(
                          "${data.name} (${data.size.toHumanReadableSize()})",
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
        );
      },
    );
  }
}
