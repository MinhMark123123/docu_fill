import 'dart:async';

import 'package:design/ui.dart';
import 'package:docu_fill/features/src/configure/components/cell_default_value.dart';
import 'package:docu_fill/features/src/configure/model/table_row_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:localization/localization.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

import '../view_model/configure_view_model.dart';
import 'cell_additional_info.dart';
import 'cell_field_description.dart';
import 'cell_field_input.dart';
import 'cell_field_key.dart';
import 'cell_field_name.dart';
import 'cell_field_options.dart';
import 'cell_field_required.dart';
import 'cell_field_section.dart';
import 'configure_edit_dialog.dart';

enum TableColumn {
  fieldKey,
  isRequired,
  fieldName,
  section,
  inputType,
  description,
  additionalInfo,
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
        return TableColumn.additionalInfo;
      case 7:
        return TableColumn.defaultValue;
      case 8:
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
      case TableColumn.additionalInfo:
        return AppLang.labelsGeneralInfo.tr();
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
    final alignment = Alignment(-1, 0);

    switch (this) {
      case TableColumn.fieldKey:
        return cellBox(child: CellFieldKey(data: data), alignment: alignment);
      case TableColumn.fieldName:
        return cellBox(
          child: CellFieldName(data: data, isReadOnly: true),
          alignment: alignment,
          padding: EdgeInsets.symmetric(
            horizontal: Dimens.size16,
            vertical: Dimens.size8,
          ),
        );
      case TableColumn.section:
        return cellBox(
          child: CellFieldSection(data: data, isReadOnly: true),
          alignment: alignment,
        );
      case TableColumn.inputType:
        return cellBox(
          child: CellFieldInput(data: data, isReadOnly: true),
          alignment: alignment,
        );
      case TableColumn.options:
        return cellBox(
          child: CellFieldOptions(data: data, isReadOnly: true),
          alignment: alignment,
        );
      case TableColumn.isRequired:
        return cellBox(
          child: CellFieldRequired(data: data, isReadOnly: true),
          alignment: alignment,
        );
      case TableColumn.defaultValue:
        return cellBox(
          child: CellDefaultValue(data: data, isReadOnly: true),
          alignment: alignment,
        );
      case TableColumn.description:
        return cellBox(
          child: CellFieldDescription(data: data, isReadOnly: true),
          alignment: alignment,
          padding: EdgeInsets.symmetric(
            horizontal: Dimens.size16,
            vertical: Dimens.size8,
          ),
        );
      case TableColumn.additionalInfo:
        return cellBox(
          child: CellAdditionalInfo(data: data, isReadOnly: true),
          alignment: alignment,
        );
    }
  }

  Widget cellBox({
    required Widget child,
    AlignmentGeometry? alignment,
    EdgeInsets? padding,
  }) {
    return Container(
      padding:
          padding ??
          EdgeInsets.symmetric(
            horizontal: Dimens.size16,
            vertical: Dimens.size16,
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
  final ScrollController _verticalController = ScrollController();
  int? _hoveredRowIndex;

  final List<TableSpanExtent> columnWidths = [
    FixedSpanExtent(200), // fieldKey
    FixedSpanExtent(100), // isRequired
    FixedSpanExtent(250), // fieldName
    FixedSpanExtent(200), // section
    FixedSpanExtent(180), // inputType
    FixedSpanExtent(300), // description
    FixedSpanExtent(250), // additionalInfo
    FixedSpanExtent(250), // defaultValue
    FixedSpanExtent(300), // options
  ];

  StreamSubscription<String>? _scrollSub;

  @override
  void initState() {
    super.initState();
    _scrollSub = getViewModel<ConfigureViewModel>().scrollRequest
        .asStream()
        .listen((key) {
          if (key.isEmpty) return;
          final index = widget.data.indexWhere((e) => e.fieldKey == key);
          if (index != -1) {
            _scrollToRow(index);
          }
        });
  }

  void _scrollToRow(int index) {
    const rowHeight = 60.0; // Using fixed height for simplicity
    final targetOffset = index * rowHeight;
    _verticalController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    _scrollSub?.cancel();
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
        verticalDetails: ScrollableDetails.vertical(
          controller: _verticalController,
          physics: const ClampingScrollPhysics(),
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
    final rowData =
        (widget.data.isEmpty || isHeader)
            ? null
            : widget.data[vicinity.row - 1];

    return TableViewCell(
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoveredRowIndex = vicinity.row),
        onExit: (_) => setState(() => _hoveredRowIndex = null),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap:
              isHeader || rowData == null
                  ? null
                  : () => _showEditDialog(context, rowData),
          child: TableColumn.from(
            vicinity,
          ).buildChild(context, vicinity: vicinity, data: rowData),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, TableRowData data) {
    showDialog(
      context: context,
      builder: (context) => ConfigureEditDialog(data: data),
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
    double rowHeight = Dimens.size66;
    double extent = isHeader ? Dimens.size60 : rowHeight;

    final Color backgroundColor =
        isHeader
            ? context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : (_hoveredRowIndex == index
                ? context.colorScheme.primaryContainer.withValues(alpha: 0.2)
                : (index % 2 == 0
                    ? context.colorScheme.inversePrimary.withValues(alpha: 0.15)
                    : context.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.1,
                    )));

    return TableSpan(
      backgroundDecoration: TableSpanDecoration(color: backgroundColor),
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
