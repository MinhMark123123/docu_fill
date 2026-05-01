import 'package:data/data.dart';
import 'package:design/ui.dart';
import 'package:docu_fill/features/src/home/components/fields_navigation_buttons.dart';
import 'package:docu_fill/features/src/home/view_model/fields_input_view_model.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class FieldsSummary extends StatelessWidget {
  const FieldsSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = getViewModel<FieldsInputViewModel>();

    return StreamDataConsumer(
      streamData: viewModel.composedTemplateUI,
      builder: (context, data) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(Dimens.size32),
          child: Column(
            spacing: Dimens.size16,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SummaryHeader(),
              const _ExportButton(),
              ...data.entries.map((entry) => _SummarySection(entry: entry)),
              Dimens.spacing.vertical(Dimens.size40),
              const FieldsNavigationButtons(),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(Dimens.size12),
          decoration: BoxDecoration(
            color: context.colorScheme.tertiary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(Dimens.size12),
          ),
          child: Icon(
            Icons.summarize_outlined,
            color: context.colorScheme.tertiary,
          ),
        ),
        Dimens.spacing.horizontal(Dimens.size16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLang.labelsInputSummary.tr(),
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                AppLang.messagesReviewBeforeExport.tr(),
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExportButton extends StatelessWidget {
  const _ExportButton();

  @override
  Widget build(BuildContext context) {
    final viewModel = getViewModel<FieldsInputViewModel>();
    return OutlinedButton.icon(
      onPressed: () => viewModel.exportSummaryText(),
      icon: const Icon(Icons.text_snippet_outlined),
      label: Text(AppLang.actionsExportSummary.tr()),
      style: OutlinedButton.styleFrom(
        foregroundColor: context.colorScheme.tertiary,
        side: BorderSide(color: context.colorScheme.tertiary),
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.size16,
          vertical: Dimens.size12,
        ),
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  final MapEntry<String, List<TemplateField>> entry;

  const _SummarySection({required this.entry});

  @override
  Widget build(BuildContext context) {
    final viewModel = getViewModel<FieldsInputViewModel>();
    final sectionFields = entry.value;

    if (sectionFields.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: Dimens.size16),
          child: Text(
            entry.key,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: context.colorScheme.primary,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: Dimens.size24,
            vertical: Dimens.size8,
          ),
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: Dimens.radii.borderMedium(),
          ),
          child: Column(
            children:
                sectionFields.map((f) => _SummaryFieldItem(field: f)).toList(),
          ),
        ),
        Dimens.spacing.vertical(Dimens.size16),
      ],
    );
  }
}

class _SummaryFieldItem extends StatelessWidget {
  final TemplateField field;

  const _SummaryFieldItem({required this.field});

  @override
  Widget build(BuildContext context) {
    final viewModel = getViewModel<FieldsInputViewModel>();
    final value = viewModel.getInitValue(e: field);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimens.size8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              field.label,
              style: context.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Dimens.spacing.horizontal(Dimens.size16),
          Expanded(
            flex: 2,
            child: Text(
              (value == null || value.isEmpty) ? "-" : value,
              style: context.textTheme.bodyMedium?.copyWith(
                color:
                    (value == null || value.isEmpty)
                        ? context.colorScheme.outline
                        : context.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
