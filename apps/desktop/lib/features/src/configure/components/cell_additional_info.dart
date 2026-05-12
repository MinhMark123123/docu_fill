import 'package:docu_fill/features/src/configure/model/table_row_data.dart';
import 'package:docu_fill/features/src/configure/view_model/configure_view_model.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:design/ui.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class CellAdditionalInfo extends StatelessWidget {
  final TableRowData data;
  final bool isReadOnly;
  final Function(String)? onChanged;

  const CellAdditionalInfo({
    super.key,
    required this.data,
    this.isReadOnly = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (isReadOnly) {
      return Text(
        data.additionalInfo ?? "",
        style: context.textTheme.bodyMedium,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }
    return TextFormField(
      initialValue: data.additionalInfo,
      decoration: InputDecoration(
        labelText: AppLang.labelsGeneralInfo.tr(),
        border: const OutlineInputBorder(),
      ),
      onChanged: (value) {
        if (onChanged != null) {
          onChanged!(value);
          return;
        }
        getViewModel<ConfigureViewModel>().updateField(
          data.fieldKey,
          (d) => d.copyWith(additionalInfo: value),
        );
      },
    );
  }
}
