import 'package:docu_fill/const/const.dart';
import 'package:docu_fill/data/src/dimensions.dart';
import 'package:docu_fill/data/src/template_field.dart';
import 'package:docu_fill/presenter/src/configure/model/table_row_data.dart';
import 'package:docu_fill/presenter/src/configure/view_model/configure_view_model.dart';
import 'package:docu_fill/ui/ui.dart';
import 'package:docu_fill/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

import 'add_on_input_text.dart';

class CellFieldOptions extends StatelessWidget {
  final TableRowData data;

  const CellFieldOptions({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
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
          onChanged: (values) {
            getViewModel<ConfigureViewModel>().updateOptions(
              data.fieldKey,
              options: values,
            );
          },
        );
    }
  }

  Widget buildImageConfig() {
    final raw = data.additionalInfo;
    final dimensions = Dimensions.from(raw);
    final widthString = dimensions?.width?.toString() ?? AppConst.empty;
    final heightString = dimensions?.height?.toString() ?? AppConst.empty;
    final unitString = dimensions?.unit?.toString() ?? AppConst.empty;
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
            onChanged: (value) {
              getViewModel<ConfigureViewModel>().updateWidthImage(
                data.fieldKey,
                widthImage: value,
              );
            },
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
            onChanged: (value) {
              getViewModel<ConfigureViewModel>().updateHeightImage(
                data.fieldKey,
                heightImage: value,
              );
            },
          ),
        ),
        Expanded(
          flex: 2,
          child: OutlineDropdownButton(
            initialValue: ImageUnit.fromValue(unitString).value,
            items: ImageUnit.values.map((e) => e.value).toList(),
            onSelected: (value) {
              getViewModel<ConfigureViewModel>().updateUnitImage(
                data.fieldKey,
                unitImage: ImageUnit.fromValue(value),
              );
            },
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
        if (value.isEmpty) {
          getViewModel<ConfigureViewModel>().updateAdditionalInfo(
            data.fieldKey,
            additionalInfo: "",
          );
          return;
        }
        getViewModel<ConfigureViewModel>().updateAdditionalInfo(
          data.fieldKey,
          additionalInfo: value,
        );
      },
    );
  }
}
