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
    return StreamDataConsumer(
      streamData: getViewModel<FieldsInputViewModel>().composedTemplateUI,
      builder: (context, data) {
        if (data.isEmpty) return SizedBox.shrink();
        return SingleChildScrollView(
          padding: EdgeInsets.all(Dimens.size16),
          child: Column(
            children:
                data.keys
                    .map(
                      (id) => _buildItem(
                        context: context,
                        templateId: id,
                        fields: data[id]!,
                      ),
                    )
                    .toList(),
          ),
        );
      },
    );
  }

  Widget _buildItem({
    required BuildContext context,
    required int templateId,
    required List<TemplateField> fields,
  }) {
    final title =
        templateId == AppConst.commonUnknow
            ? AppLang.labelsTemplates.tr()
            : getViewModel<FieldsInputViewModel>().getTemplateName(templateId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: Dimens.size24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colorScheme.primary,
                ),
              ),
              Dimens.spacing.vertical(Dimens.size4),
              Container(
                width: Dimens.size40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(Dimens.size24),
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerHighest.withOpacity(0.2),
            borderRadius: Dimens.radii.borderLarge(),
            border: Border.all(
              color: context.colorScheme.outlineVariant.withOpacity(0.5),
            ),
          ),
          child: Column(
            spacing: Dimens.size20,
            children: fields.map((e) => _buildItemField(context, e)).toList(),
          ),
        ),
        Dimens.spacing.vertical(Dimens.size32),
      ],
    );
  }

  Widget _buildItemField(BuildContext context, TemplateField e) {
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
