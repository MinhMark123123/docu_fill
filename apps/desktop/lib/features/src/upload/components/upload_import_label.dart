import 'package:design/ui.dart';
import 'package:docu_fill/features/src/upload/view_model/upload_view_model.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class UploadImportLabel extends StatelessWidget {
  const UploadImportLabel({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = getViewModel<UploadViewModel>();
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: "${AppLang.messagesDragAndDropDocx.tr()} ",
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          TextSpan(
            text: AppLang.messagesImportSetting.tr(),
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.primary,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
            recognizer:
                TapGestureRecognizer()..onTap = () => viewModel.importSetting(),
          ),
        ],
      ),
    );
  }
}
