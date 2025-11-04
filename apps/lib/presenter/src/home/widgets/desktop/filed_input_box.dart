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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          templateId == AppConst.commonUnknow
              ? AppLang.labelsTemplates.tr()
              : getViewModel<FieldsInputViewModel>().getTemplateName(
                templateId,
              ),
          style: context.textTheme.displayLarge,
        ),
        Dimens.spacing.vertical(Dimens.size16),
        Column(
          spacing: Dimens.size16,
          mainAxisSize: MainAxisSize.min,
          children: fields.map((e) => _buildItemField(context, e)).toList(),
        ),
      ],
    );
  }

  Widget _buildItemField(BuildContext context, TemplateField e) {
    switch (e.type) {
      case FieldType.text:
        return textInputItem(context, e);
      case FieldType.datetime:
        return dateTimeItem(context, e);
      case FieldType.selection:
        return selectionItem(context, e);
      case FieldType.image:
        return imagePickItem(context, e);
      case FieldType.singleLine:
        return textInputItem(context, e);
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

  Widget selectionItem(BuildContext context, TemplateField e) {
    return itemField(
      context: context,
      isRequired: e.required,
      title: e.label,
      child: OutlineDropdownButton(
        initialValue: e.options?.firstOrNull,
        items: e.options ?? [],
        onSelected:
            (value) => getViewModel<FieldsInputViewModel>().setValue(
              field: e,
              value: value,
            ),
      ),
    );
  }

  Widget dateTimeItem(BuildContext context, TemplateField e) {
    return itemField(
      context: context,
      isRequired: e.required,
      title: e.label,
      child: DateTimePickerButton(
        onDateTimeChanged: (time) {
          getViewModel<FieldsInputViewModel>().setValue(
            field: e,
            value: time?.toString(),
          );
        },
      ),
    );
  }

  Widget textInputItem(BuildContext context, TemplateField e) {
    return itemField(
      context: context,
      isRequired: e.required,
      title: e.label,
      child: TextFormField(
        key: Key(e.key),
        initialValue: e.defaultValue,
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
    final textStyle = context.textTheme.bodyMedium;
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: RichText(
            text: TextSpan(
              style: textStyle,
              // Default style for all TextSpans unless overridden
              children: <TextSpan>[
                TextSpan(text: title),
                if (isRequired)
                  TextSpan(
                    text: ' *',
                    // Note the space before the asterisk for better visual separation
                    style: textStyle?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                TextSpan(text: " :"),
              ],
            ),
          ),
        ),
        Expanded(flex: 2, child: child),
      ],
    );
  }
}
