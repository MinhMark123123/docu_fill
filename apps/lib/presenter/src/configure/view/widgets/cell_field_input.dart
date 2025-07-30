import 'package:docu_fill/data/src/template_field.dart';
import 'package:docu_fill/presenter/src/configure/model/table_row_data.dart';
import 'package:docu_fill/presenter/src/configure/view_model/configure_view_model.dart';
import 'package:flutter/material.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

import 'field_type_drop_down.dart';

class CellFieldInput extends StatelessWidget {
  final TableRowData data;

  const CellFieldInput({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return EnumDropdownButton(
      initialValue: data.inputType,
      onChanged: (FieldType? value) {
        getViewModel<ConfigureViewModel>().setValue(
          data.fieldKey,
          inputType: value,
        );
      },
    );
  }
}
