import 'package:localization/localization.dart';
import 'package:docu_fill/features/src/configure/model/table_row_data.dart';
import 'package:docu_fill/features/src/configure/view_model/configure_view_model.dart';
import 'package:flutter/material.dart';
import 'package:design/ui.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class CellFieldSection extends StatelessWidget {
  final TableRowData data;
  final bool isReadOnly;
  final Function(String)? onChanged;

  const CellFieldSection({
    super.key,
    required this.data,
    this.isReadOnly = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (isReadOnly) {
      return Text(
        data.section ?? "",
        style: context.textTheme.bodyMedium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    return TextFormField(
      initialValue: data.section,
      decoration: InputDecoration(
        labelText: AppLang.labelsSection.tr(),
        border: const OutlineInputBorder(),
      ),
      onChanged: (value) {
        if (onChanged != null) {
          onChanged!(value);
          return;
        }
        getViewModel<ConfigureViewModel>().updateField(
          data.fieldKey,
          (d) => d.copyWith(section: value),
        );
      },
    );
  }
}
