import 'package:docu_fill/core/core.dart';
import 'package:docu_fill/ui/ui.dart';
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
        title: const Text("Settings"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Dimens.size24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGeminiSection(context, viewModel),
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
                  "Gemini AI Configuration",
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Dimens.spacing.vertical(Dimens.size16),
            const Text(
              "In order to use the 'Import from File' feature, you need to provide a Gemini API Key.",
              style: TextStyle(height: 1.5),
            ),
            Dimens.spacing.vertical(Dimens.size24),
            TextField(
              controller: viewModel.apiKeyController,
              decoration: const InputDecoration(
                labelText: "Gemini API Key",
                hintText: "Enter your API key here",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.key),
              ),
              obscureText: true,
            ),
            Dimens.spacing.vertical(Dimens.size24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => viewModel.saveSettings(),
                icon: const Icon(Icons.save),
                label: const Text("Save Gemini Settings"),
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
