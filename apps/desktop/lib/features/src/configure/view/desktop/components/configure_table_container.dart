import 'package:design/ui.dart';
import 'package:docu_fill/features/src/configure/view/widgets/configure_table_fields.dart';
import 'package:docu_fill/features/src/configure/view_model/configure_view_model.dart';
import 'package:flutter/material.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class ConfigureTableContainer extends StatelessWidget {
  const ConfigureTableContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = getViewModel<ConfigureViewModel>();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: Dimens.radii.borderLarge(),
        border: Border.all(
          color: context.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: StreamDataConsumer(
        streamData: viewModel.fieldsData,
        builder: (context, data) {
          return CustomScrollableTable(data: data);
        },
      ),
    );
  }
}
