import 'package:design/ui.dart';
import 'package:docu_fill/features/src/setting/components/gemini_config_fields.dart';
import 'package:docu_fill/features/src/setting/components/gemini_log_actions.dart';
import 'package:docu_fill/features/src/setting/components/gemini_model_selector.dart';
import 'package:docu_fill/features/src/setting/view_model/setting_view_model.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class GeminiSection extends StatelessWidget {
  const GeminiSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: Dimens.radii.borderMedium()),
      child: Padding(
        padding: EdgeInsets.all(Dimens.size24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _GeminiHeader(),
            Dimens.spacing.vertical(Dimens.size16),
            Text(
              AppLang.messagesGeminiConfigDesc.tr(),
              style: const TextStyle(height: 1.5),
            ),
            Dimens.spacing.vertical(Dimens.size24),
            const GeminiConfigFields(),
            Dimens.spacing.vertical(Dimens.size24),
            const GeminiModelSelector(),
            Dimens.spacing.vertical(Dimens.size24),
            const GeminiLogActions(),
            Dimens.spacing.vertical(Dimens.size24),
            const _SaveButton(),
          ],
        ),
      ),
    );
  }
}

class _GeminiHeader extends StatelessWidget {
  const _GeminiHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton();

  @override
  Widget build(BuildContext context) {
    final viewModel = getViewModel<SettingViewModel>();
    return SizedBox(
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
    );
  }
}
