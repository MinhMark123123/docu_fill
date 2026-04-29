import 'package:design/ui.dart';
import 'package:docu_fill/features/src/configure/model/table_row_data.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

class CellFieldDescription extends StatelessWidget {
  final TableRowData data;

  const CellFieldDescription({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return ReactiveTextFormField(
      key: Key("${data.fieldKey}_description"),
      initialValue: data.description,
      maxLines: 1,
      onChanged: (value) {
        data.description = value;
      },
      decoration: InputDecoration(
        hintText: AppLang.labelsPrompt.tr(),
        isDense: true,
      ),
    );
  }
}
