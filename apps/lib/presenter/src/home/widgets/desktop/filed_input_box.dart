import 'package:docu_fill/const/const.dart';
import 'package:docu_fill/data/src/template_field.dart';
import 'package:docu_fill/presenter/src/home/view_model/fields_input_view_model.dart';
import 'package:docu_fill/presenter/src/home/widgets/image_picker_widget.dart';
import 'package:docu_fill/ui/src/atom/date_time_picker_button.dart';
import 'package:docu_fill/ui/src/atom/outline_dropdown_button.dart';
import 'package:docu_fill/ui/src/methodology/tokens/dimens.dart';
import 'package:docu_fill/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class FiledInputBox extends StatelessWidget {
  const FiledInputBox({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = getViewModel<FieldsInputViewModel>();
    return StreamDataConsumer(
      streamData: viewModel.composedTemplateUI,
      builder: (context, data) {
        if (data.isEmpty) return SizedBox.shrink();
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Sidebar Navigation ---
            _buildSidebar(context, viewModel),

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
                      return _buildSectionContent(context, sectionKey, fields);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSidebar(BuildContext context, FieldsInputViewModel viewModel) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: context.colorScheme.outlineVariant.withOpacity(0.5),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(Dimens.size24),
            child: Text(
              AppLang.labelsConfigureTemplateFields.tr(),
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colorScheme.primary,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: viewModel.sections.length,
              itemBuilder: (context, index) {
                return StreamDataConsumer(
                  streamData: viewModel.currentSectionIndex,
                  builder: (context, currentIndex) {
                    final isSelected = currentIndex == index;
                    final sectionKey = viewModel.sections[index];
                    return InkWell(
                      onTap: () => viewModel.updateCurrentSectionIndex(index),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimens.size24,
                          vertical: Dimens.size16,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? context.colorScheme.primaryContainer
                                      .withOpacity(0.3)
                                  : Colors.transparent,
                          border: Border(
                            left: BorderSide(
                              color:
                                  isSelected
                                      ? context.colorScheme.primary
                                      : Colors.transparent,
                              width: 4,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getSectionIcon(sectionKey),
                              size: Dimens.size20,
                              color:
                                  isSelected
                                      ? context.colorScheme.primary
                                      : context.colorScheme.onSurfaceVariant,
                            ),
                            Dimens.spacing.horizontal(Dimens.size16),
                            Expanded(
                              child: Text(
                                sectionKey,
                                style: context.textTheme.bodyMedium?.copyWith(
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                  color:
                                      isSelected
                                          ? context.colorScheme.primary
                                          : context.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContent(
    BuildContext context,
    String sectionTitle,
    List<TemplateField> fields,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(Dimens.size32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(Dimens.size12),
                decoration: BoxDecoration(
                  color: context.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(Dimens.size12),
                ),
                child: Icon(
                  _getSectionIcon(sectionTitle),
                  color: context.colorScheme.primary,
                ),
              ),
              Dimens.spacing.horizontal(Dimens.size16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sectionTitle,
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Please fill in the information below.",
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Dimens.spacing.vertical(Dimens.size32),
          Container(
            padding: EdgeInsets.all(Dimens.size32),
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHighest.withOpacity(
                0.1,
              ),
              borderRadius: Dimens.radii.borderLarge(),
              border: Border.all(
                color: context.colorScheme.outlineVariant.withOpacity(0.3),
              ),
            ),
            child: Column(
              spacing: Dimens.size24,
              children: fields.map((e) => buildItemField(context, e)).toList(),
            ),
          ),
          Dimens.spacing.vertical(Dimens.size40),
          _buildNavigationButtons(context),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    final viewModel = getViewModel<FieldsInputViewModel>();
    return StreamDataConsumer(
      streamData: viewModel.currentSectionIndex,
      builder: (context, index) {
        final isFirst = index == 0;
        final isLast = index == viewModel.sections.length - 1;

        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (!isFirst || viewModel.showSummary.data)
              OutlinedButton.icon(
                onPressed: () => viewModel.previousSection(),
                icon: Icon(Icons.arrow_back),
                label: Text(AppLang.actionsBack.tr()),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimens.size24,
                    vertical: Dimens.size16,
                  ),
                ),
              ),
            Dimens.spacing.horizontal(Dimens.size16),
            if (!isLast || !viewModel.showSummary.data)
              ElevatedButton.icon(
                onPressed: () => viewModel.nextSection(),
                icon: Icon(
                  isLast ? Icons.summarize_outlined : Icons.arrow_forward,
                ),
                label: Text(
                  isLast ? AppLang.actionsView.tr() : AppLang.actionsNext.tr(),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimens.size32,
                    vertical: Dimens.size16,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSummary(BuildContext context, FieldsInputViewModel viewModel) {
    final data = viewModel.composedTemplateUI.data;
    return SingleChildScrollView(
      padding: EdgeInsets.all(Dimens.size32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Input Summary",
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Please review all information before exporting.",
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Dimens.spacing.vertical(Dimens.size32),
          ...data.entries.map((entry) {
            final sectionFields = entry.value.where(
              (f) => viewModel.getInitValue(e: f) != null,
            );
            if (sectionFields.isEmpty) return SizedBox.shrink();

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
                    color: context.colorScheme.surfaceContainerHighest
                        .withOpacity(0.3),
                    borderRadius: Dimens.radii.borderMedium(),
                  ),
                  child: Column(
                    children:
                        sectionFields.map((f) {
                          final value = viewModel.getInitValue(e: f);
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: Dimens.size8,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    f.label,
                                    style: context.textTheme.bodySmall
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Dimens.spacing.horizontal(Dimens.size16),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    value ?? "-",
                                    style: context.textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                ),
                Dimens.spacing.vertical(Dimens.size16),
              ],
            );
          }),
          Dimens.spacing.vertical(Dimens.size40),
          _buildNavigationButtons(context),
        ],
      ),
    );
  }

  IconData _getSectionIcon(String sectionKey) {
    if (sectionKey == AppLang.labelsCommon.tr()) return Icons.layers;
    if (sectionKey == AppLang.labelsGeneral.tr()) return Icons.info_outline;
    return Icons.folder_open;
  }

  Widget buildItemField(BuildContext context, TemplateField e) {
    final viewModel = getViewModel<FieldsInputViewModel>();
    switch (e.type) {
      case FieldType.text:
        return textInputItem(context, e, viewModel);
      case FieldType.datetime:
        return dateTimeItem(context, e, viewModel);
      case FieldType.selection:
        return selectionItem(context, e, viewModel);
      case FieldType.image:
        return imagePickItem(context, e);
      case FieldType.singleLine:
        return textInputItem(context, e, viewModel);
    }
  }

  Widget imagePickItem(BuildContext context, TemplateField e) {
    return itemField(
      context: context,
      isRequired: e.required,
      title: e.label,
      child: ImagePickerWidget(
        imageFiled: e,
        onImageChanged: (image) {
          getViewModel<FieldsInputViewModel>().setValue(
            field: e,
            value: image?.path,
          );
        },
      ),
    );
  }

  Widget selectionItem(
    BuildContext context,
    TemplateField e,
    FieldsInputViewModel viewModel,
  ) {
    return itemField(
      context: context,
      isRequired: e.required,
      title: e.label,
      child: OutlineDropdownButton(
        initialValue: viewModel.getInitValue(e: e),
        items: e.options ?? [],
        onSelected:
            (value) => getViewModel<FieldsInputViewModel>().setValue(
              field: e,
              value: value,
            ),
      ),
    );
  }

  Widget dateTimeItem(
    BuildContext context,
    TemplateField e,
    FieldsInputViewModel viewModel,
  ) {
    print("build ${DateTime.tryParse(viewModel.getInitValue(e: e) ?? "")}");

    return itemField(
      context: context,
      isRequired: e.required,
      title: e.label,
      child: DateTimePickerButton(
        initialDateTime: DateTime.tryParse(viewModel.getInitValue(e: e) ?? ""),
        onDateTimeChanged: (time) {
          getViewModel<FieldsInputViewModel>().setValue(
            field: e,
            value: time?.toString(),
          );
        },
      ),
    );
  }

  Widget textInputItem(
    BuildContext context,
    TemplateField e,
    FieldsInputViewModel viewModel,
  ) {
    return itemField(
      context: context,
      isRequired: e.required,
      title: e.label,
      child: TextFormField(
        key: Key(e.key),
        initialValue: viewModel.getInitValue(e: e),
        maxLines: 8,
        minLines: 1,
        decoration: InputDecoration(
          hintText:
              e.type == FieldType.text
                  ? AppLang.messagesInputTextHint.tr()
                  : AppLang.messagesSingleLineTextHint.tr(),
        ),
        onChanged: (value) {
          getViewModel<FieldsInputViewModel>().setValue(field: e, value: value);
        },
      ),
    );
  }

  Widget itemField({
    required BuildContext context,
    required String title,
    required Widget child,
    bool isRequired = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimens.size4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colorScheme.onSurface,
              ),
              children: <TextSpan>[
                TextSpan(text: title),
                if (isRequired)
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: context.colorScheme.error),
                  ),
              ],
            ),
          ),
          Dimens.spacing.vertical(Dimens.size8),
          child,
        ],
      ),
    );
  }
}
