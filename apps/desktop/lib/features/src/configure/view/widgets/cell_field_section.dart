import 'package:core/const/src/app_lang.dart';
import 'package:docu_fill/features/src/configure/model/table_row_data.dart';
import 'package:docu_fill/features/src/configure/view_model/configure_view_model.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class CellFieldSection extends StatelessWidget {
  final TableRowData data;
  const CellFieldSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: data.section,
      decoration: InputDecoration(
        labelText: AppLang.labelsSection.tr(),
        border: const OutlineInputBorder(),
      ),
      onChanged: (value) {
        getViewModel<ConfigureViewModel>().updateSection(
          data.fieldKey,
          section: value,
        );
      },
    );
  }
}
