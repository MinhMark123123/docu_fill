import 'package:design/ui.dart';
import 'package:docu_fill/features/src/configure/model/table_row_data.dart';
import 'package:docu_fill/features/src/configure/view_model/configure_view_model.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class CellFieldDescription extends StatelessWidget {
  final TableRowData data;
  final bool isReadOnly;
  final Function(String)? onChanged;

  const CellFieldDescription({
    super.key,
    required this.data,
    this.isReadOnly = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (isReadOnly) {
      return Tooltip(
        mouseCursor: MouseCursor.defer,
        message: data.description ?? "",
        child: Text(
          data.description ?? "",
          style: context.textTheme.bodyMedium,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
    return ReactiveTextFormField(
      key: Key("${data.fieldKey}_description"),
      initialValue: data.description,
      maxLines: 4,
      onChanged: (value) {
        if (onChanged != null) {
          onChanged!(value);
          return;
        }
        getViewModel<ConfigureViewModel>().updateField(
          data.fieldKey,
          (d) => d.copyWith(description: value),
        );
      },
      decoration: InputDecoration(
        hintText: AppLang.labelsPrompt.tr(),
        isDense: true,
      ),
    );
  }
}
