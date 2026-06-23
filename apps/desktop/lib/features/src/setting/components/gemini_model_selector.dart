import 'package:design/ui.dart';
import 'package:docu_fill/features/src/setting/view_model/setting_view_model.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class GeminiModelSelector extends StatelessWidget {
  const GeminiModelSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = getViewModel<SettingViewModel>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          streamData: viewModel.availableModels,
          builder: (context, List<String> availableModels) {
            return StreamDataConsumer(
              streamData: viewModel.selectedModel,
              builder: (context, String selectedModel) {
                final items = availableModels.contains(selectedModel)
                    ? availableModels
                    : [...availableModels, selectedModel];

                return DropdownButtonFormField<String>(
                  value: items.contains(selectedModel) ? selectedModel : null,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onChanged: (String? newValue) => viewModel.onModelSelected(newValue),
                  items: items.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
