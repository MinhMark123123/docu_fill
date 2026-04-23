import 'package:localization/localization.dart';
import 'package:core/core.dart';
import 'package:docu_fill/gen/assets.gen.dart';
import 'package:docu_fill/features/src/upload/view_model/upload_view_model.dart';
import 'package:design/ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class UploadLayoutDesktop extends StatelessWidget {
  const UploadLayoutDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: Dimens.size928),
          padding: EdgeInsets.symmetric(
            horizontal: Dimens.size24,
            vertical: Dimens.size40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              header(context),
              Dimens.spacing.vertical(Dimens.size32),
              dropBox(context),
              Dimens.spacing.vertical(Dimens.size24),
              bottomLabel(context),
              Dimens.spacing.vertical(Dimens.size40),
              continueButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget continueButton() => StreamDataConsumer(
    streamData: getViewModel<UploadViewModel>().filePicked,
    builder: (context, data) {
      final isVisible = data.path != null;
      return AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: IgnorePointer(
          ignoring: !isVisible,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(Dimens.size200, Dimens.size48),
              backgroundColor: context.colorScheme.primary,
              foregroundColor: context.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: Dimens.radii.borderMedium(),
              ),
            ),
            onPressed: () {
              getViewModel<UploadViewModel>().continuePressed();
            },
            child: Text(
              AppLang.actionsContinue.tr(),
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    },
  );

  Widget dropBox(BuildContext context) {
    return GestureDetector(
      onTap: () => getViewModel<UploadViewModel>().pickFile(),
      child: Container(
        width: double.infinity,
        height: Dimens.size232 * 1.2,
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: Dimens.radii.borderLarge(),
          border: Border.all(
            color: context.colorScheme.primary.withOpacity(0.5),
            width: 2,
            style: BorderStyle.solid,
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
              filePickedBuilder(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget header(BuildContext context) {
    return Column(
      children: [
        Text(
          AppLang.actionsUploadTemplate.tr(),
          style: context.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colorScheme.onSurface,
          ),
        ),
        Dimens.spacing.vertical(Dimens.size8),
        Text(
          AppLang.messagesUploadTemplate.tr(),
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget bottomLabel(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: "${AppLang.messagesDragAndDropDocx.tr()} ",
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          TextSpan(
            text: AppLang.messagesImportSetting.tr(),
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.primary,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
            recognizer:
                TapGestureRecognizer()
                  ..onTap =
                      () => getViewModel<UploadViewModel>().importSetting(),
          ),
        ],
      ),
    );
  }

  Widget filePickedBuilder(BuildContext context) {
    return StreamDataConsumer(
      streamData: getViewModel<UploadViewModel>().filePicked,
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
                        Assets.images.png.imageDocument.image(
                          width: Dimens.size30,
                        ),
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
