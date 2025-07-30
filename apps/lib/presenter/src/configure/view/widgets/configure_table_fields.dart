import 'package:docu_fill/const/const.dart';
import 'package:docu_fill/presenter/src/configure/model/table_row_data.dart';
import 'package:docu_fill/ui/src/methodology/tokens/dimens.dart';
import 'package:docu_fill/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

import 'cell_field_input.dart';
import 'cell_field_key.dart';
import 'cell_field_name.dart';
import 'cell_field_options.dart';
import 'cell_field_required.dart';

enum TableColumn {
  fieldKey,
  isRequired,
  fieldName,
  inputType,
  options;

  static TableColumn from(TableVicinity vicinity) {
    switch (vicinity.column) {
      case 0:
        return TableColumn.fieldKey;
      case 1:
        return TableColumn.isRequired;
      case 2:
        return TableColumn.fieldName;
      case 3:
        return TableColumn.inputType;
      case 4:
        return TableColumn.options;
      default:
        return TableColumn.isRequired;
    }
  }

  String labels() {
    switch (this) {
      case TableColumn.fieldKey:
        return AppLang.labelsFieldKey.tr();
      case TableColumn.fieldName:
        return AppLang.labelsFieldName.tr();
      case TableColumn.inputType:
        return AppLang.labelsInputType.tr();
      case TableColumn.options:
        return AppLang.labelsOptions.tr();
      case TableColumn.isRequired:
        return AppLang.labelsRequired.tr();
    }
  }

  Widget buildChild(
    BuildContext context, {
    required TableVicinity vicinity,
    required TableRowData? data,
  }) {
    if (vicinity.row == 0) {
      //build Header
      return cellBox(child: Text(labels(), style: context.textTheme.bodySmall));
    }
    if (data == null) return const SizedBox();
    switch (this) {
      case TableColumn.fieldKey:
        return cellBox(child: CellFieldKey(data: data));
      case TableColumn.fieldName:
        return cellBox(child: CellFieldName(data: data));
      case TableColumn.inputType:
        return cellBox(child: CellFieldInput(data: data));
      case TableColumn.options:
        return cellBox(child: CellFieldOptions(data: data));
      case TableColumn.isRequired:
        return cellBox(child: CellFieldRequired(data: data));
    }
  }

  Widget cellBox({required Widget child}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.size16,
        vertical: Dimens.size12,
      ),
      alignment: Alignment(-1, 0),
      child: child,
    );
  }
}

class CustomScrollableTable extends StatelessWidget {
  final List<TableRowData> data; // Your table data

  // Define column widths - you can adjust these as needed
  // Using FixedTableSpanExtent for fixed widths, but you can explore others.
  final List<TableSpanExtent> columnWidths = [
    FractionalSpanExtent(0.15), // Field Key
    FractionalSpanExtent(0.1), // Required
    FractionalSpanExtent(0.25), // Field Name
    FractionalSpanExtent(0.2), // Input Type
    FractionalSpanExtent(0.3), // Options
  ];

  CustomScrollableTable({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return TableView.builder(
      columnCount: TableColumn.values.length,
      rowCount: data.length + 1,
      // Pin the header row
      pinnedRowCount: 1,
      cellBuilder: (context, vicinity) => _buildCell(context, vicinity),
      columnBuilder: (index) => _buildColumnSpan(context, index),
      rowBuilder: (index) => _buildRowSpan(context, index),
    );
  }

  TableViewCell _buildCell(BuildContext context, TableVicinity vicinity) {
    final isHeader = vicinity.row == 0;
    return TableViewCell(
      child: TableColumn.from(vicinity).buildChild(
        context,
        vicinity: vicinity,
        data: (data.isEmpty || isHeader) ? null : data[vicinity.row - 1],
      ),
    );
  }

  TableSpan _buildColumnSpan(BuildContext context, int index) {
    return TableSpan(
      foregroundDecoration: TableSpanDecoration(
        border: TableSpanBorder(
          // For the outer vertical lines
          leading: index == 0 ? borderSideDecoration(context) : BorderSide.none,
          trailing:
              index == TableColumn.values.length - 1
                  ? borderSideDecoration(context)
                  : BorderSide.none,
        ),
      ),
      extent: columnWidths[index],
    );
  }

  TableSpan _buildRowSpan(BuildContext context, int index) {
    return TableSpan(
      foregroundDecoration: TableSpanDecoration(
        border: TableSpanBorder(
          leading: index == 0 ? borderSideDecoration(context) : BorderSide.none,
          trailing:
              (index == data.length || index == 0)
                  ? borderSideDecoration(context)
                  : BorderSide.none,
        ),
      ),
      extent:
          index == 0
              ? FixedSpanExtent(Dimens.size46)
              : FixedSpanExtent(Dimens.size72),
    );
  }

  BorderSide borderSideDecoration(BuildContext context) {
    return BorderSide(
      width: Dimens.size1.w,
      color: context.appColors?.dashColor ?? Colors.transparent,
    );
  }
}
