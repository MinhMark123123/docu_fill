import 'package:design/ui.dart';
import 'package:docu_fill/features/src/upload/view_model/upload_view_model.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class UploadContinueButton extends StatelessWidget {
  const UploadContinueButton({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = getViewModel<UploadViewModel>();
    return StreamDataConsumer(
      streamData: viewModel.filePicked,
      builder: (context, data) {
        final isVisible = data.path != null;
        return AnimatedOpacity(
          opacity: isVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: IgnorePointer(
            ignoring: !isVisible,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(Dimens.size200, Dimens.size48),
                backgroundColor: context.colorScheme.primary,
                foregroundColor: context.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: Dimens.radii.borderMedium(),
                ),
              ),
              onPressed: () => viewModel.continuePressed(),
              child: Text(
                AppLang.actionsContinue.tr(),
                style: context.textTheme.titleMedium?.copyWith(
                  color: context.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
