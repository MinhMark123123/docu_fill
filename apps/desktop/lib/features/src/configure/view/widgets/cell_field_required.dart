import 'package:docu_fill/features/page.dart';
import 'package:docu_fill/features/src/configure/model/table_row_data.dart';
import 'package:design/ui.dart';
import 'package:flutter/material.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class CellFieldRequired extends StatelessWidget {
  final TableRowData data;

  const CellFieldRequired({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: Dimens.size8),
      child: Checkbox(
        value: data.isRequired,
        onChanged:
            (value) => getViewModel<ConfigureViewModel>().updateField(
              data.fieldKey,
              (d) => d.copyWith(isRequired: value),
            ),
      ),
    );
  }
}
