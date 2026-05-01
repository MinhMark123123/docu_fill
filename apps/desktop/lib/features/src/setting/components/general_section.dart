import 'package:design/ui.dart';
import 'package:docu_fill/features/src/setting/view_model/setting_view_model.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class GeneralSection extends StatelessWidget {
  const GeneralSection({super.key});

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
            const _GeneralHeader(),
            Dimens.spacing.vertical(Dimens.size16),
            const _LanguageSelector(),
          ],
        ),
      ),
    );
  }
}

class _GeneralHeader extends StatelessWidget {
  const _GeneralHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector();

  @override
  Widget build(BuildContext context) {
    final viewModel = getViewModel<SettingViewModel>();
    return ListTile(
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
    );
  }
}
