import 'package:design/ui.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

/// In-app user guide: what to do in situations users commonly run into
/// while filling values from imported files.
class UserGuideDialog extends StatelessWidget {
  const UserGuideDialog({super.key});

  static Future<void> show(BuildContext context) => showDialog<void>(
    context: context,
    builder: (_) => const UserGuideDialog(),
  );

  // (title, body) in reading order: how it works first, then problems.
  static const _items = [
    (AppLang.guideItemsHowItWorksTitle, AppLang.guideItemsHowItWorksBody),
    (AppLang.guideItemsYellowTitle, AppLang.guideItemsYellowBody),
    (AppLang.guideItemsQuestionMarksTitle, AppLang.guideItemsQuestionMarksBody),
    (AppLang.guideItemsEmptyTitle, AppLang.guideItemsEmptyBody),
    (AppLang.guideItemsFirstUseTitle, AppLang.guideItemsFirstUseBody),
    (AppLang.guideItemsSlowTitle, AppLang.guideItemsSlowBody),
    (AppLang.guideItemsCancelTitle, AppLang.guideItemsCancelBody),
    (AppLang.guideItemsWrongTitle, AppLang.guideItemsWrongBody),
    (AppLang.guideItemsPdfQualityTitle, AppLang.guideItemsPdfQualityBody),
    (AppLang.guideItemsOtherMachineTitle, AppLang.guideItemsOtherMachineBody),
    (AppLang.guideItemsNotInstalledTitle, AppLang.guideItemsNotInstalledBody),
    (AppLang.guideItemsPrivacyTitle, AppLang.guideItemsPrivacyBody),
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.help_outline, color: context.colorScheme.primary),
          Dimens.spacing.horizontal(Dimens.size12),
          Text(AppLang.guideTitle.tr()),
        ],
      ),
      content: SizedBox(
        width: 640,
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(AppLang.guideIntro.tr(), style: context.textTheme.bodyMedium),
            Dimens.spacing.vertical(Dimens.size12),
            for (final (title, body) in _items)
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.only(bottom: Dimens.size12),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                title: Text(
                  title.tr(),
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                children: [
                  SelectableText(
                    body.tr(),
                    style: context.textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                ],
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).closeButtonLabel),
        ),
      ],
    );
  }
}
