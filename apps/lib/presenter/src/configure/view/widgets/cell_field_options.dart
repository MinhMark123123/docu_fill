import 'package:docu_fill/const/src/app_lang.dart';
import 'package:docu_fill/data/src/template_field.dart';
import 'package:docu_fill/presenter/src/configure/model/table_row_data.dart';
import 'package:docu_fill/presenter/src/configure/view_model/configure_view_model.dart';
import 'package:docu_fill/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

import 'add_on_input_text.dart';

class CellFieldOptions extends StatelessWidget {
  final TableRowData data;

  const CellFieldOptions({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.inputType != FieldType.selection) {
      return SizedBox.shrink();
    }
    if (data.inputType == FieldType.selection) {
      return SizedBox.shrink();
    }
    if (data.inputType == FieldType.datetime) {
      return TextFormField(
        initialValue: data.additionalInfo,
        decoration: InputDecoration(
          labelText: AppLang.messagesEnterDateFormat.tr(),
          border: const OutlineInputBorder(),
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return AppLang.messagesEnterDateFormat.tr();
          }
          if (!DateTimeUtils.flexibleDateValidator(value)) {
            return AppLang.messagesDateFormatInvalid.tr();
          }
          return null;
        },

        onChanged: (value) {
          if (value.isEmpty) {
            getViewModel<ConfigureViewModel>().setValue(
              data.fieldKey,
              additionalInfo: "",
            );
            return;
          }
          if (!DateTimeUtils.flexibleDateValidator(value)) {
            return;
          }
          getViewModel<ConfigureViewModel>().setValue(
            data.fieldKey,
            additionalInfo: value,
          );
        },
      );
    }
    return AddOnInputText(
      onChanged: (values) {
        getViewModel<ConfigureViewModel>().setValue(
          data.fieldKey,
          options: values,
        );
      },
    );
  }
}
