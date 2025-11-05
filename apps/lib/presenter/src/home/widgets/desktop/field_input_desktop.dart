import 'package:docu_fill/presenter/src/home/view_model/home_view_model.dart';
import 'package:docu_fill/presenter/src/home/widgets/desktop/field_input_confirm_box.dart';
import 'package:docu_fill/presenter/src/home/widgets/desktop/filed_input_box.dart';
import 'package:docu_fill/presenter/src/home/widgets/empty_fields_widget.dart';
import 'package:docu_fill/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class FieldInputDesktop extends StatelessWidget {
  const FieldInputDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamDataConsumer(
      streamData: getViewModel<HomeViewModel>().composed,
      builder: (context, data) {
        if (data.$1.isEmpty) return EmptyFieldsWidget();
        return Column(
          children: [FieldInputConfirmBox(), Expanded(child: FiledInputBox())],
        );
      },
    );
  }

  Widget decorationBox({required Widget child}) {
    return Padding(
      padding: EdgeInsets.only(bottom: Dimens.size8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: Dimens.radii.borderSmall()),
        elevation: Dimens.size1,
        child: child,
      ),
    );
  }
}
