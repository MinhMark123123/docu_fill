import 'package:design/ui.dart';
import 'package:docu_fill/features/src/setting/view_model/setting_view_model.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class GeminiLogActions extends StatelessWidget {
  const GeminiLogActions({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = getViewModel<SettingViewModel>();
    return Column(
      children: [
        StreamDataConsumer(
          streamData: viewModel.enableApiLogging,
          builder: (context, bool isLogging) {
            return SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(AppLang.settingsGeminiEnableLogging.tr()),
              value: isLogging,
              onChanged: (value) => viewModel.onToggleApiLogging(value),
            );
          },
        ),
        Dimens.spacing.vertical(Dimens.size12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => viewModel.navigateToLogHistory(context),
            icon: const Icon(Icons.history),
            label: Text(AppLang.labelsLogHistory.tr()),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.all(Dimens.size16),
              shape: RoundedRectangleBorder(
                borderRadius: Dimens.radii.borderMedium(),
              ),
            ),
          ),
        ),
        Dimens.spacing.vertical(Dimens.size12),
        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: () => viewModel.openLogsFolder(),
            icon: const Icon(Icons.folder_open),
            label: Text(AppLang.settingsGeminiOpenLogs.tr()),
          ),
        ),
      ],
    );
  }
}
