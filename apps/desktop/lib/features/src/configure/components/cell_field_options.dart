import 'package:localization/localization.dart';
import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:docu_fill/features/src/configure/model/table_row_data.dart';
import 'package:docu_fill/features/src/configure/view_model/configure_view_model.dart';
import 'package:design/ui.dart';
import 'package:flutter/material.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

import 'add_on_input_text.dart';

class CellFieldOptions extends StatelessWidget {
  final TableRowData data;
  final bool isReadOnly;
  final Function(TableRowData)? onChanged;

  const CellFieldOptions({
    super.key,
    required this.data,
    this.isReadOnly = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (isReadOnly) {
      return _buildReadOnly(context);
    }
    switch (data.inputType) {
      case FieldType.text:
      case FieldType.singleLine:
        return SizedBox.shrink();
      case FieldType.image:
        return buildImageConfig();
      case FieldType.datetime:
        return buildDateTimeFormat();
      case FieldType.selection:
        return AddOnInputText(
          initValue: data.options,
          onChanged: (values) {
            if (onChanged != null) {
              onChanged!(data.copyWith(options: values));
              return;
            }
            getViewModel<ConfigureViewModel>().updateField(
              data.fieldKey,
              (d) => d.copyWith(options: values),
            );
          },
        );
    }
  }

  Widget _buildReadOnly(BuildContext context) {
    switch (data.inputType) {
      case FieldType.text:
      case FieldType.singleLine:
        return const SizedBox.shrink();
      case FieldType.image:
        final dimensions = Dimensions.from(data.additionalInfo);
        if (dimensions == null) return const Text("-");
        return Text(
          "${dimensions.width} x ${dimensions.height} ${dimensions.unit}",
          style: context.textTheme.bodyMedium,
        );
      case FieldType.datetime:
        return Text(
          data.additionalInfo ?? "-",
          style: context.textTheme.bodyMedium,
        );
      case FieldType.selection:
        final options = data.options ?? [];
        if (options.isEmpty) return const Text("-");
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: options
                .map(
                  (e) => Padding(
                    padding: EdgeInsets.only(right: Dimens.size4),
                    child: Chip(
                      label: Text(e, style: context.textTheme.labelSmall),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                )
                .toList(),
          ),
        );
    }
  }

  Widget buildImageConfig() {
    final raw = data.additionalInfo;
    final dimensions = Dimensions.from(raw);
    final widthString = dimensions?.width?.toString() ?? AppConst.empty;
    final heightString = dimensions?.height?.toString() ?? AppConst.empty;
    final unitString = dimensions?.unit?.toString() ?? AppConst.empty;

    void updateDimension(String value, int index) {
      if (onChanged != null) {
        final parts = (data.additionalInfo ?? ";;${ImageUnit.cm.value}").split(";");
        if (parts.length >= 3) {
          parts[index] = value;
          onChanged!(data.copyWith(additionalInfo: parts.join(";")));
        }
        return;
      }
      if (index == 0) {
        getViewModel<ConfigureViewModel>().updateWidthImage(data.fieldKey, value);
      } else if (index == 1) {
        getViewModel<ConfigureViewModel>().updateHeightImage(data.fieldKey, value);
      } else {
        getViewModel<ConfigureViewModel>().updateUnitImage(data.fieldKey, ImageUnit.fromValue(value));
      }
    }

    return Row(
      spacing: Dimens.size8,
      children: [
        Expanded(
          child: TextFormField(
            initialValue: widthString,
            decoration: InputDecoration(
              labelText: AppLang.labelsWidth.tr(),
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) => updateDimension(value, 0),
          ),
        ),
        Expanded(
          child: TextFormField(
            initialValue: heightString,
            decoration: InputDecoration(
              labelText: AppLang.labelsHeight.tr(),
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) => updateDimension(value, 1),
          ),
        ),
        Expanded(
          flex: 2,
          child: OutlineDropdownButton(
            initialValue: ImageUnit.fromValue(unitString).value,
            items: ImageUnit.values.map((e) => e.value).toList(),
            onSelected: (value) => updateDimension(value ?? "", 2),
          ),
        ),
      ],
    );
  }

  TextFormField buildDateTimeFormat() {
    return TextFormField(
      initialValue: data.additionalInfo,
      decoration: InputDecoration(
        labelText: AppLang.messagesEnterDateFormat.tr(),
        border: const OutlineInputBorder(),
      ),
      onChanged: (value) {
        if (onChanged != null) {
          onChanged!(data.copyWith(additionalInfo: value));
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
