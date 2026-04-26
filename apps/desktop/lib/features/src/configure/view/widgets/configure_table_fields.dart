import 'package:data/data.dart';
import 'package:design/ui.dart';
import 'package:docu_fill/features/src/configure/model/table_row_data.dart';
import 'package:docu_fill/features/src/configure/view/widgets/cell_default_value.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:localization/localization.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

import 'cell_field_description.dart';
import 'cell_field_input.dart';
import 'cell_field_key.dart';
import 'cell_field_name.dart';
import 'cell_field_options.dart';
import 'cell_field_required.dart';
import 'cell_field_section.dart';

enum TableColumn {
  fieldKey,
  isRequired,
  fieldName,
  section,
  inputType,
  description,
  defaultValue,
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
        return TableColumn.section;
      case 4:
        return TableColumn.inputType;
      case 5:
        return TableColumn.description;
      case 6:
        return TableColumn.defaultValue;
      case 7:
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
      case TableColumn.section:
        return AppLang.labelsSection.tr();
      case TableColumn.inputType:
        return AppLang.labelsInputType.tr();
      case TableColumn.options:
        return AppLang.labelsOptions.tr();
      case TableColumn.isRequired:
        return AppLang.labelsRequired.tr();
      case TableColumn.defaultValue:
        return AppLang.labelsDefaultValue.tr();
      case TableColumn.description:
        return AppLang.labelsPrompt.tr();
    }
  }

  Widget buildChild(
    BuildContext context, {
    required TableVicinity vicinity,
    required TableRowData? data,
  }) {
    if (vicinity.row == 0) {
      return cellBox(child: Text(labels(), style: context.textTheme.bodySmall));
    }
    if (data == null) return const SizedBox();
    final alignment =
        data.inputType == FieldType.selection ? Alignment(-1, -1) : null;

    switch (this) {
      case TableColumn.fieldKey:
        return cellBox(child: CellFieldKey(data: data), alignment: alignment);
      case TableColumn.fieldName:
        return cellBox(child: CellFieldName(data: data), alignment: alignment);
      case TableColumn.section:
        return cellBox(
          child: CellFieldSection(data: data),
          alignment: alignment,
        );
      case TableColumn.inputType:
        return cellBox(child: CellFieldInput(data: data), alignment: alignment);
      case TableColumn.options:
        return cellBox(
          child: CellFieldOptions(data: data),
          alignment: alignment,
        );
      case TableColumn.isRequired:
        return cellBox(
          child: CellFieldRequired(data: data),
          alignment: alignment,
        );
      case TableColumn.defaultValue:
        return cellBox(
          child: CellDefaultValue(data: data),
          alignment: alignment,
        );
      case TableColumn.description:
        return cellBox(
          child: CellFieldDescription(data: data),
          alignment: alignment,
        );
    }
  }

  Widget cellBox({required Widget child, AlignmentGeometry? alignment}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.size16,
        vertical: Dimens.size12,
      ),
      alignment: alignment ?? Alignment(-1, 0),
      child: child,
    );
  }
}

class CustomScrollableTable extends StatefulWidget {
  final List<TableRowData> data;

  const CustomScrollableTable({super.key, required this.data});

  @override
  State<CustomScrollableTable> createState() => _CustomScrollableTableState();
}

class _CustomScrollableTableState extends State<CustomScrollableTable> {
  final ScrollController _horizontalController = ScrollController();

  final List<TableSpanExtent> columnWidths = [
    FixedSpanExtent(200), // fieldKey
    FixedSpanExtent(100), // isRequired
    FixedSpanExtent(250), // fieldName
    FixedSpanExtent(200), // section
    FixedSpanExtent(180), // inputType
    FixedSpanExtent(300), // description
    FixedSpanExtent(250), // defaultValue
    FixedSpanExtent(300), // options
  ];

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _horizontalController,
      thumbVisibility: true,
      trackVisibility: true,
      scrollbarOrientation: ScrollbarOrientation.bottom,
      child: TableView.builder(
        verticalDetails: const ScrollableDetails.vertical(
          physics: ClampingScrollPhysics(),
        ),
        horizontalDetails: ScrollableDetails.horizontal(
          controller: _horizontalController,
          physics: const ClampingScrollPhysics(),
        ),
        columnCount: TableColumn.values.length,
        rowCount: widget.data.length + 1,
        pinnedRowCount: 1,
        cellBuilder: (context, vicinity) => _buildCell(context, vicinity),
        columnBuilder: (index) => _buildColumnSpan(context, index),
        rowBuilder: (index) => _buildRowSpan(context, index),
      ),
    );
  }

  TableViewCell _buildCell(BuildContext context, TableVicinity vicinity) {
    final isHeader = vicinity.row == 0;
    return TableViewCell(
      child: TableColumn.from(vicinity).buildChild(
        context,
        vicinity: vicinity,
        data:
            (widget.data.isEmpty || isHeader)
                ? null
                : widget.data[vicinity.row - 1],
      ),
    );
  }

  TableSpan _buildColumnSpan(BuildContext context, int index) {
    return TableSpan(
      foregroundDecoration: TableSpanDecoration(
        border: TableSpanBorder(
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
    final isHeader = index == 0;
    double extent = isHeader ? Dimens.size46 : Dimens.size72;

    if (!isHeader && widget.data.isNotEmpty) {
      final rowData = widget.data[index - 1];
      if (rowData.inputType == FieldType.selection) {
        final optionsCount = rowData.options?.length ?? 1;
        final calculatedHeight =
            (optionsCount * (Dimens.size40 + Dimens.size12)) +
            Dimens.size48 +
            Dimens.size40;
        if (calculatedHeight > extent) {
          extent = calculatedHeight;
        }
      }
    }

    return TableSpan(
      foregroundDecoration: TableSpanDecoration(
        border: TableSpanBorder(
          leading: isHeader ? borderSideDecoration(context) : BorderSide.none,
          trailing:
              (index == widget.data.length || isHeader)
                  ? borderSideDecoration(context)
                  : BorderSide.none,
        ),
      ),
      extent: FixedSpanExtent(extent),
    );
  }

  BorderSide borderSideDecoration(BuildContext context) {
    return BorderSide(
      width: Dimens.size1.w,
      color: context.appColors?.dashColor ?? Colors.transparent,
    );
  }
}
