import 'package:docu_fill/data/data.dart';
import 'package:docu_fill/presenter/src/home/view_model/fields_input_view_model.dart';
import 'package:docu_fill/presenter/src/home/widgets/desktop/field_input_confirm_box.dart';
import 'package:docu_fill/presenter/src/home/widgets/desktop/filed_input_box.dart';
import 'package:docu_fill/presenter/src/home/widgets/empty_fields_widget.dart';
import 'package:docu_fill/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class FieldInputMobile extends StatelessWidget {
  const FieldInputMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = getViewModel<FieldsInputViewModel>();
    return StreamDataConsumer(
      streamData: viewModel.idsSelected,
      builder: (context, ids) {
        if (ids.isEmpty) return EmptyFieldsWidget();
        return StreamDataConsumer(
          streamData: viewModel.composedTemplateUI,
          builder: (context, data) {
            if (data.isEmpty) return SizedBox.shrink();

            return Column(
              children: [
                _buildProgressIndicator(context, viewModel),
                Expanded(
                  child: StreamDataConsumer(
                    streamData: viewModel.showSummary,
                    builder: (context, showSummary) {
                      if (showSummary) {
                        return _buildSummary(context, viewModel);
                      }
                      return StreamDataConsumer(
                        streamData: viewModel.currentSectionIndex,
                        builder: (context, index) {
                          final sectionKey = viewModel.sections[index];
                          final fields = data[sectionKey] ?? [];
                          return _buildSectionContent(
                            context,
                            sectionKey,
                            fields,
                          );
                        },
                      );
                    },
                  ),
                ),
                _buildBottomNavigation(context, viewModel),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildProgressIndicator(
    BuildContext context,
    FieldsInputViewModel viewModel,
  ) {
    return StreamDataConsumer(
      streamData: viewModel.currentSectionIndex,
      builder: (context, index) {
        final total = viewModel.sections.length;
        final progress = (index + 1) / total;

        return Column(
          children: [
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.1),
              minHeight: 4,
            ),
            Padding(
              padding: EdgeInsets.all(Dimens.size16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Step ${index + 1} of $total",
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  StreamDataConsumer(
                    streamData: viewModel.showSummary,
                    builder: (context, showSummary) {
                      final sectionKey =
                          showSummary ? "Summary" : viewModel.sections[index];
                      return Text(
                        sectionKey,
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionContent(
    BuildContext context,
    String sectionTitle,
    List<TemplateField> fields,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(Dimens.size16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sectionTitle,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          Dimens.spacing.vertical(Dimens.size16),
          ...fields.map((f) => _buildItemField(context, f)),
          Dimens.spacing.vertical(Dimens.size32),
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context, FieldsInputViewModel viewModel) {
    final data = viewModel.composedTemplateUI.data;
    return SingleChildScrollView(
      padding: EdgeInsets.all(Dimens.size16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Review Summary",
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          Dimens.spacing.vertical(Dimens.size16),
          FieldInputConfirmBox(),
          Dimens.spacing.vertical(Dimens.size24),
          ...data.entries.map((entry) {
            final sectionFields = entry.value.where(
              (f) => viewModel.getInitValue(e: f) != null,
            );
            if (sectionFields.isEmpty) return SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: Dimens.size12),
                  child: Text(
                    entry.key,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                ...sectionFields.map((f) {
                  final value = viewModel.getInitValue(e: f);
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: Dimens.size4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            f.label,
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Dimens.spacing.horizontal(Dimens.size8),
                        Expanded(
                          flex: 3,
                          child: Text(
                            value ?? "-",
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                Divider(height: Dimens.size24),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(
    BuildContext context,
    FieldsInputViewModel viewModel,
  ) {
    return StreamDataConsumer(
      streamData: viewModel.currentSectionIndex,
      builder: (context, index) {
        final isFirst = index == 0;
        final isLast = index == viewModel.sections.length - 1;

        return Container(
          padding: EdgeInsets.all(Dimens.size16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                if (!isFirst || viewModel.showSummary.data)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => viewModel.previousSection(),
                      child: Text("Back"),
                    ),
                  ),
                if (!isFirst || viewModel.showSummary.data)
                  Dimens.spacing.horizontal(Dimens.size12),
                if (!viewModel.showSummary.data)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => viewModel.nextSection(),
                      child: Text(isLast ? "Review" : "Next"),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildItemField(BuildContext context, TemplateField e) {
    return Padding(
      padding: EdgeInsets.only(bottom: Dimens.size20),
      child: FiledInputBox().buildItemField(context, e),
    );
  }
}
