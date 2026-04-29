import 'package:design/ui.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

class UploadHeader extends StatelessWidget {
  const UploadHeader({super.key});

  @override
  Widget build(BuildContext context) {
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
}
