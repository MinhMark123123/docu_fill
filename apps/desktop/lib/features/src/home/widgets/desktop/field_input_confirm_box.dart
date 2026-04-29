import 'package:design/ui.dart';
import 'package:docu_fill/features/src/home/view_model/fields_input_view_model.dart';
import 'package:docu_fill/features/src/home/widgets/desktop/components/field_input_confirm_widgets.dart';
import 'package:flutter/material.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class FieldInputConfirmBox extends StatelessWidget {
  const FieldInputConfirmBox({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = getViewModel<FieldsInputViewModel>();
    return Container(
      padding: EdgeInsets.all(Dimens.size24),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: context.colorScheme.outlineVariant.withOpacity(0.5),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreamDataConsumer(
            streamData: viewModel.showSummary,
            builder: (context, showSummary) {
              if (!showSummary) return const QuickActionsRow();
              return const _SummaryActions();
            },
          ),
        ],
      ),
    );
  }
}

class _SummaryActions extends StatelessWidget {
  const _SummaryActions();

  @override
  Widget build(BuildContext context) {
    final viewModel = getViewModel<FieldsInputViewModel>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ExportSection(),
        _StatusIndicators(viewModel: viewModel),
        Dimens.spacing.vertical(Dimens.size20),
        const QuickActionsRow(),
      ],
    );
  }
}

class _StatusIndicators extends StatelessWidget {
  final FieldsInputViewModel viewModel;

  const _StatusIndicators({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StreamDataConsumer(
          streamData: viewModel.isExportSuccess,
          builder: (context, isSuccess) {
            if (!isSuccess) return const SizedBox.shrink();
            return Padding(
              padding: EdgeInsets.only(top: Dimens.size16),
              child: ExportSuccessMessage(),
            );
          },
        ),
        StreamDataConsumer(
          streamData: viewModel.missingKeys,
          builder: (context, data) {
            if (data.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: EdgeInsets.only(top: Dimens.size16),
              child: MissingKeysWarning(data: data),
            );
          },
        ),
      ],
    );
  }
}
