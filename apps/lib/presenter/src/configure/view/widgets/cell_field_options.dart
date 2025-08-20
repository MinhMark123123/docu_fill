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
    print("----------> ${data.inputType}");
    switch (data.inputType) {
      case FieldType.text:
      case FieldType.image:
        return SizedBox.shrink();
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
        TextFormField(
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
        TextFormField(
          initialValue: widthString,
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
        DropdownButton<ImageUnit>(
          value: ImageUnit.cm,
          onChanged: (value) {
            getViewModel<ConfigureViewModel>().updateUnitImage(
              data.fieldKey,
              unitImage: value,
            );
          },
          items:
              ImageUnit.values
                  .map((e) => DropdownMenuItem<ImageUnit>(child: Text(e.value)))
                  .toList(),
        ),
      ],
    );
  }

  TextFormField buildDateTimeFormat() {
    return TextFormField(
      initialValue: data.additionalInfo,
      decoration: InputDecoration(
        labelText: AppLang.labelsWidth.tr(),
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
        if (!DateTimeUtils.flexibleDateValidator(value)) {
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
