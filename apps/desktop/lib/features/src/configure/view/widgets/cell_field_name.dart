import 'package:localization/localization.dart';
import 'package:docu_fill/features/src/configure/model/table_row_data.dart';
import 'package:docu_fill/features/src/configure/view_model/configure_view_model.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class CellFieldName extends StatelessWidget {
  final TableRowData data;
  const CellFieldName({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: data.fieldName,
      decoration: InputDecoration(
        labelText: AppLang.labelsInputFieldName.tr(),
        border: const OutlineInputBorder(),
      ),
      onChanged: (value) {
        getViewModel<ConfigureViewModel>().updateFieldName(
          data.fieldKey,
          fieldName: value,
        );
      },
    );
  }
}
