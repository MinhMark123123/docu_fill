import 'package:data/data.dart';
import 'package:design/ui.dart';
import 'package:docu_fill/features/src/configure/model/table_row_data.dart';
import 'package:docu_fill/features/src/configure/view_model/configure_view_model.dart';
import 'package:flutter/material.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

import 'field_type_drop_down.dart';

class CellFieldInput extends StatelessWidget {
  final TableRowData data;
  final bool isReadOnly;
  final Function(FieldType?)? onChanged;

  const CellFieldInput({
    super.key,
    required this.data,
    this.isReadOnly = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (isReadOnly) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          border: Border.all(),
          borderRadius: Dimens.radii.borderMedium(),
        ),
        child: Text(
          data.inputType.label(),
        ),
      );
    }
    return EnumDropdownButton(
      initialValue: data.inputType,
      onChanged: (FieldType? value) {
        if (onChanged != null) {
          onChanged!(value);
          return;
        }
        getViewModel<ConfigureViewModel>().updateField(
          data.fieldKey,
          (d) => d.copyWith(inputType: value),
        );
      },
    );
  }
}
