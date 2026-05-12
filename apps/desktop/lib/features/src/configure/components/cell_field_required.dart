import 'package:docu_fill/features/page.dart';
import 'package:docu_fill/features/src/configure/model/table_row_data.dart';
import 'package:design/ui.dart';
import 'package:flutter/material.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class CellFieldRequired extends StatelessWidget {
  final TableRowData data;
  final bool isReadOnly;
  final Function(bool?)? onChanged;

  const CellFieldRequired({
    super.key,
    required this.data,
    this.isReadOnly = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (isReadOnly) {
      return Icon(
        data.isRequired ? Icons.check_circle : Icons.radio_button_unchecked,
        color: data.isRequired ? Colors.green : context.colorScheme.outline,
        size: 20,
      );
    }
    return Padding(
      padding: EdgeInsets.only(left: Dimens.size8),
      child: Checkbox(
        value: data.isRequired,
        onChanged: (value) {
          if (onChanged != null) {
            onChanged!(value);
            return;
          }
          getViewModel<ConfigureViewModel>().updateField(
            data.fieldKey,
            (d) => d.copyWith(isRequired: value),
          );
        },
      ),
    );
  }
}
