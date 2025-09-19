import 'package:docu_fill/presenter/src/configure/model/table_row_data.dart';
import 'package:docu_fill/utils/src/context_extension.dart';
import 'package:flutter/material.dart';

class CellFieldKey extends StatelessWidget {
  final TableRowData data;

  const CellFieldKey({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      mouseCursor: MouseCursor.defer,
      message: data.fieldKey,
      child: Text(
        data.fieldKey,
        style: context.textTheme.bodySmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
