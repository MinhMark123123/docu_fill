import 'package:design/ui.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

class LogHistoryEmpty extends StatelessWidget {
  const LogHistoryEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off,
            size: 64,
            color: context.colorScheme.outline,
          ),
          Dimens.spacing.vertical(Dimens.size16),
          Text(
            AppLang.messagesNoLogsFound.tr(),
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
