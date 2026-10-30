import 'package:design/ui.dart';
import 'package:docu_fill/features/src/setting/view_model/setting_view_model.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class DataSection extends StatelessWidget {
  const DataSection({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = getViewModel<SettingViewModel>();
    return Card(
      shape: RoundedRectangleBorder(borderRadius: Dimens.radii.borderMedium()),
      child: Padding(
        padding: EdgeInsets.all(Dimens.size24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics_outlined, color: context.colorScheme.primary),
                Dimens.spacing.horizontal(Dimens.size12),
                Text(
                  AppLang.settingsDataTitle.tr(),
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Dimens.spacing.vertical(Dimens.size12),
            Text(
              AppLang.settingsDataDescription.tr(),
              style: context.textTheme.bodyMedium,
            ),
            Dimens.spacing.vertical(Dimens.size16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: viewModel.exportAnalysisData,
                icon: const Icon(Icons.archive_outlined),
                label: Text(AppLang.settingsDataExport.tr()),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.all(Dimens.size16),
                  shape: RoundedRectangleBorder(
                    borderRadius: Dimens.radii.borderMedium(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
