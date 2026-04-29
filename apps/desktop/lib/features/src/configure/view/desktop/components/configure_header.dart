import 'package:design/ui.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

class ConfigureHeader extends StatelessWidget {
  const ConfigureHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLang.labelsConfigureTemplateFields.tr(),
          style: context.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colorScheme.onSurface,
          ),
        ),
        Dimens.spacing.vertical(Dimens.size8),
        Text(
          AppLang.messagesReviewAndConfigureFields.tr(),
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
