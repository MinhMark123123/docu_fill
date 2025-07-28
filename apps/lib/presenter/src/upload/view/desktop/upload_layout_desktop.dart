import 'package:docu_fill/const/const.dart';
import 'package:docu_fill/gen/assets.gen.dart';
import 'package:docu_fill/presenter/page.dart';
import 'package:docu_fill/ui/ui.dart';
import 'package:docu_fill/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class UploadLayoutDesktop extends StatelessWidget {
  const UploadLayoutDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimens.size20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Dimens.spacing.vertical(Dimens.size20),
            header(context),
            dropBox(context),
            bottomLabel(context),
            continueButton(),
          ],
        ),
      ),
    );
  }

  Expanded continueButton() => Expanded(
    child: Center(
      child: StreamDataConsumer(
        streamData: getViewModel<UploadViewModel>().filePicked,
        builder: (context, data) {
          return Visibility(
            visible: data.path != null,
            maintainAnimation: true,
            maintainState: true,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  context.colorScheme.primary,
                ),
              ),
              onPressed: () {
                getViewModel<UploadViewModel>().continuePressed();
              },
              child: Text(AppLang.actionsContinue.tr()),
            ),
          );
        },
      ),
    ),
  );

  AspectRatio dropBox(BuildContext context) {
    return AspectRatio(
      aspectRatio: 960 / 264,
      child: Padding(
        padding: EdgeInsets.all(Dimens.size16),
        child: DashedBorderContainer(
          strokeWidth: Dimens.size2,
          dashWidth: Dimens.size8,
          borderColor: context.appColors?.dashColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLang.messagesDragAndDropDocx.tr(),
                style: context.textTheme.headlineSmall,
              ),
              Dimens.spacing.vertical(Dimens.size8),
              Text(
                AppLang.actionsBrowseFiles.tr(),
                style: context.textTheme.bodySmall,
              ),
              Dimens.spacing.vertical(Dimens.size34),
              filePickedBuilder(context),
              FilledButton(
                onPressed: () => getViewModel<UploadViewModel>().pickFile(),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: Dimens.size4),
                  child: Text(
                    AppLang.labelsUploadDocxFile.tr(),
                    style: context.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget header(BuildContext context) {
    return AspectRatio(
      aspectRatio: 960 / 105,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimens.size16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLang.actionsUploadTemplate.tr(),
              style: context.textTheme.displayLarge,
            ),
            Dimens.spacing.vertical(Dimens.size12),
            Text(
              AppLang.messagesUploadTemplate.tr(),
              style: context.textTheme.bodySmall?.copyWith(
                color: context.appColors?.bodyTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget bottomLabel(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Text(
        AppLang.messagesDragAndDropDocx.tr(),
        style: context.textTheme.bodySmall?.copyWith(
          color: context.appColors?.bodyTextColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget filePickedBuilder(BuildContext context) {
    return StreamDataConsumer(
      streamData: getViewModel<UploadViewModel>().filePicked,
      builder: (context, data) {
        return AnimatedSize(
          duration: Duration(milliseconds: 200),
          child:
              data.path == null
                  ? SizedBox.shrink()
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
                            color: context.appColors?.bodyTextColor,
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
