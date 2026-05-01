import 'package:design/ui.dart';
import 'package:docu_fill/features/src/setting/view_model/setting_view_model.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class GeminiConfigFields extends StatelessWidget {
  const GeminiConfigFields({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = getViewModel<SettingViewModel>();
    return Column(
      children: [
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
        TextField(
          controller: viewModel.studyDataController,
          decoration: InputDecoration(
            labelText: AppLang.settingsGeminiStudyData.tr(),
            hintText: "Enter study data or rules to help Gemini understand the context",
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.menu_book),
          ),
          maxLines: 5,
          minLines: 3,
        ),
        Dimens.spacing.vertical(Dimens.size24),
        TextField(
          controller: viewModel.sampleResultController,
          decoration: InputDecoration(
            labelText: AppLang.settingsGeminiSampleResult.tr(),
            hintText: "Enter a sample JSON result to guide the output format",
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.data_object),
          ),
          maxLines: 5,
          minLines: 3,
        ),
      ],
    );
  }
}
