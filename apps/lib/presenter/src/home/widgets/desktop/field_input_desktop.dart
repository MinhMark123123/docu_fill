import 'package:docu_fill/const/const.dart';
import 'package:docu_fill/data/src/template_field.dart';
import 'package:docu_fill/presenter/src/home/view_model/fields_input_view_model.dart';
import 'package:docu_fill/presenter/src/home/widgets/desktop/field_input_confirm_box.dart';
import 'package:docu_fill/presenter/src/widgets/desktop_top_title.dart';
import 'package:docu_fill/ui/ui.dart';
import 'package:docu_fill/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class FieldInputDesktop extends StatelessWidget {
  const FieldInputDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamDataConsumer(
      streamData: getViewModel<FieldsInputViewModel>().template,
      builder: (context, data) {
        return Column(
          children: [
            DesktopTopTitle(
              aspectRatio: 960 / 105,
              title: data.templateName,
              subtitle: AppLang.labelsConfigureTemplateFields.tr(),
            ),
            Dimens.spacing.horizontal(Dimens.size16),
            if (data.fields.isNotEmpty)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimens.size16),
                  child: SingleChildScrollView(
                    child: Column(
                      spacing: Dimens.size16,
                      children: [
                        FieldInputConfirmBox(),
                        ...data.fields.map((e) => _buildItemField(context, e)),
                        Dimens.spacing.horizontal(Dimens.size16),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildItemField(BuildContext context, TemplateField e) {
    switch (e.type) {
      case FieldType.text:
        return itemField(
          context: context,
          isRequired: e.required,
          title: e.label,
          child: TextField(
            decoration: InputDecoration(
              hintText: AppLang.messagesInputTextHint.tr(),
            ),
            onChanged: (value) {
              getViewModel<FieldsInputViewModel>().setValue(
                key: e.key,
                value: value,
              );
            },
          ),
        );
      case FieldType.datetime:
        return itemField(
          context: context,
          isRequired: e.required,
          title: e.label,
          child: DateTimePickerButton(
            onDateTimeChanged: (time) {
              getViewModel<FieldsInputViewModel>().setValue(
                key: e.key,
                value: time?.toString(),
              );
            },
          ),
        );
      case FieldType.selection:
        return itemField(
          context: context,
          isRequired: e.required,
          title: e.label,
          child: OutlineDropdownButton(
            initialValue: e.options?.firstOrNull,
            items: e.options ?? [],
            onSelected:
                (value) => getViewModel<FieldsInputViewModel>().setValue(
                  key: e.key,
                  value: value,
                ),
          ),
        );
    }
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
