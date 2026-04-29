import 'package:design/ui.dart';
import 'package:docu_fill/core/src/base_view.dart';
import 'package:docu_fill/features/src/setting/components/gemini_section.dart';
import 'package:docu_fill/features/src/setting/components/general_section.dart';
import 'package:docu_fill/features/src/setting/view_model/setting_view_model.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

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
            GeneralSection(),
            Dimens.spacing.vertical(Dimens.size24),
            GeminiSection(),
          ],
        ),
      ),
    );
  }
}
