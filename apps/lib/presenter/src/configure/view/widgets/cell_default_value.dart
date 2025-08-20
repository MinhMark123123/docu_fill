import 'package:docu_fill/const/src/app_lang.dart';
import 'package:docu_fill/data/data.dart';
import 'package:docu_fill/presenter/src/configure/model/table_row_data.dart';
import 'package:docu_fill/presenter/src/configure/view_model/configure_view_model.dart';
import 'package:docu_fill/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class CellDefaultValue extends StatelessWidget {
  final TableRowData data;

  const CellDefaultValue({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.inputType == FieldType.selection) {
      return SizedBox.shrink();
    }
    return TextFormField(
      initialValue: data.additionalInfo,
      decoration: InputDecoration(
        labelText: AppLang.labelsDefaultValue.tr(),
        border: const OutlineInputBorder(),
      ),
      onChanged: (value) {
        getViewModel<ConfigureViewModel>().updateDefaultValue(
          data.fieldKey,
          defaultValue: value,
        );
      },
    );
  }
}
