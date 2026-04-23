import 'package:core/core.dart';
import 'package:docu_fill/core/core.dart';
import 'package:design/ui.dart';
import 'package:flutter/material.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

import 'view_model/setting_view_model.dart';

class SettingPage extends BaseView<SettingViewModel> {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context, SettingViewModel viewModel) {
    return Scaffold(
      backgroundColor: context.appColors?.containerBackground,
      appBar: AppBar(
        title: Text(AppLang.labelsSettings.tr()),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Dimens.size24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGeneralSection(context, viewModel),
            Dimens.spacing.vertical(Dimens.size24),
            _buildGeminiSection(context, viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralSection(
    BuildContext context,
    SettingViewModel viewModel,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: Dimens.radii.borderMedium()),
      child: Padding(
        padding: EdgeInsets.all(Dimens.size24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: context.colorScheme.primary),
                Dimens.spacing.horizontal(Dimens.size12),
                Text(
                  AppLang.settingsGeneralTitle.tr(),
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Dimens.spacing.vertical(Dimens.size16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(AppLang.settingsGeneralLanguage.tr()),
              trailing: DropdownButton<Locale>(
                value: context.locale,
                onChanged: (Locale? newLocale) {
                  if (newLocale != null) {
                    viewModel.changeLocale(context, newLocale);
                  }
                },
                items: [
                  DropdownMenuItem(
                    value: const Locale('en', 'US'),
                    child: Text(AppLang.settingsGeneralEnglish.tr()),
                  ),
                  DropdownMenuItem(
                    value: const Locale('vi', 'VN'),
                    child: Text(AppLang.settingsGeneralVietnamese.tr()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeminiSection(BuildContext context, SettingViewModel viewModel) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: Dimens.radii.borderMedium()),
      child: Padding(
        padding: EdgeInsets.all(Dimens.size24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: context.colorScheme.primary),
                Dimens.spacing.horizontal(Dimens.size12),
                Text(
                  AppLang.settingsGeminiTitle.tr(),
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Dimens.spacing.vertical(Dimens.size16),
            Text(
              AppLang.messagesGeminiConfigDesc.tr(),
              style: const TextStyle(height: 1.5),
            ),
            Dimens.spacing.vertical(Dimens.size24),
            TextField(
              controller: viewModel.apiKeyController,
              decoration: InputDecoration(
                labelText: AppLang.settingsGeminiApiKey.tr(),
                hintText: AppLang.messagesGeminiApiKeyHint.tr(),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.key),
              ),
              obscureText: true,
            ),
            Dimens.spacing.vertical(Dimens.size24),
            Text(
              AppLang.settingsGeminiModel.tr(),
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Dimens.spacing.vertical(Dimens.size8),
            Text(
              AppLang.messagesGeminiModelDesc.tr(),
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            Dimens.spacing.vertical(Dimens.size12),
            StreamDataConsumer(
              streamData: viewModel.selectedModel,
              builder: (context, String selectedModel) {
                return DropdownButtonFormField<String>(
                  value: selectedModel,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onChanged: (String? newValue) {
                    viewModel.onModelSelected(newValue);
                  },
                  items:
                      viewModel.availableModels.map<DropdownMenuItem<String>>((
                        String value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                );
              },
            ),
            Dimens.spacing.vertical(Dimens.size24),
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
            Dimens.spacing.vertical(Dimens.size24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => viewModel.saveGeminiApiKey(),
                icon: const Icon(Icons.save),
                label: Text(AppLang.settingsGeminiSaveBtn.tr()),
                style: ElevatedButton.styleFrom(
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
