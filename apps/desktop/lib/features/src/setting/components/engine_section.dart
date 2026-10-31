import 'package:design/ui.dart';
import 'package:docu_fill/features/src/setting/view_model/setting_view_model.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

/// Choice between the offline engine and Gemini, and offline engine options.
class EngineSection extends StatelessWidget {
  const EngineSection({super.key});

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
                Icon(Icons.memory, color: context.colorScheme.primary),
                Dimens.spacing.horizontal(Dimens.size12),
                Text(
                  AppLang.settingsEngineTitle.tr(),
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Dimens.spacing.vertical(Dimens.size12),
            Text(
              AppLang.settingsEngineDescription.tr(),
              style: context.textTheme.bodyMedium,
            ),
            if (!viewModel.offlineEngineInstalled) ...[
              Dimens.spacing.vertical(Dimens.size8),
              Text(
                AppLang.settingsEngineNotInstalled.tr(),
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.error,
                ),
              ),
            ],
            Dimens.spacing.vertical(Dimens.size16),
            StreamDataConsumer(
              streamData: viewModel.mappingEngine,
              builder: (context, String engine) {
                return SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: 'offline',
                      enabled: viewModel.offlineEngineInstalled,
                      icon: const Icon(Icons.lock_outline),
                      label: Text(AppLang.settingsEngineOffline.tr()),
                    ),
                    ButtonSegment(
                      value: 'gemini',
                      icon: const Icon(Icons.cloud_outlined),
                      label: Text(AppLang.settingsEngineGemini.tr()),
                    ),
                  ],
                  selected: {engine},
                  onSelectionChanged:
                      (selected) =>
                          viewModel.onMappingEngineSelected(selected.first),
                );
              },
            ),
            Dimens.spacing.vertical(Dimens.size12),
            StreamDataConsumer(
              streamData: viewModel.useLocalLlm,
              builder: (context, bool enabled) {
                return SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(AppLang.settingsEngineUseLlm.tr()),
                  subtitle: Text(AppLang.settingsEngineUseLlmDescription.tr()),
                  value: enabled,
                  onChanged:
                      viewModel.offlineEngineInstalled
                          ? viewModel.onToggleLocalLlm
                          : null,
                );
              },
            ),
            Dimens.spacing.vertical(Dimens.size12),
            Text(
              AppLang.settingsEngineCasesFolderDescription.tr(),
              style: context.textTheme.bodySmall,
            ),
            Dimens.spacing.vertical(Dimens.size8),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: viewModel.openSharedCasesFolder,
                icon: const Icon(Icons.folder_shared_outlined),
                label: Text(AppLang.settingsEngineOpenCasesFolder.tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
