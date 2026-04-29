import 'package:design/ui.dart';
import 'package:docu_fill/features/src/home/view_model/fields_input_view_model.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class FieldsNavigationButtons extends StatelessWidget {
  const FieldsNavigationButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = getViewModel<FieldsInputViewModel>();
    return StreamDataConsumer(
      streamData: viewModel.currentSectionIndex,
      builder: (context, index) {
        final isFirst = index == 0;
        final isLast = index == viewModel.sections.length - 1;
        final showSummary = viewModel.showSummary.data;

        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (!isFirst || showSummary) const _BackButton(),
            Dimens.spacing.horizontal(Dimens.size16),
            if (!isLast || !showSummary) _NextButton(isLast: isLast),
          ],
        );
      },
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    final viewModel = getViewModel<FieldsInputViewModel>();
    return OutlinedButton.icon(
      onPressed: () => viewModel.previousSection(),
      icon: const Icon(Icons.arrow_back),
      label: Text(AppLang.actionsBack.tr()),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.size24,
          vertical: Dimens.size16,
        ),
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  final bool isLast;

  const _NextButton({required this.isLast});

  @override
  Widget build(BuildContext context) {
    final viewModel = getViewModel<FieldsInputViewModel>();
    return ElevatedButton.icon(
      onPressed: () => viewModel.nextSection(),
      icon: Icon(isLast ? Icons.summarize_outlined : Icons.arrow_forward),
      label: Text(isLast ? AppLang.actionsView.tr() : AppLang.actionsNext.tr()),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.size32,
          vertical: Dimens.size16,
        ),
      ),
    );
  }
}
