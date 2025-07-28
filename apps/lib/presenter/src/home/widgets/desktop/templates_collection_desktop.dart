import 'package:docu_fill/const/const.dart';
import 'package:docu_fill/presenter/src/home/view_model/home_view_model.dart';
import 'package:docu_fill/presenter/src/home/widgets/item_document_collection.dart';
import 'package:docu_fill/ui/ui.dart';
import 'package:docu_fill/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class TemplatesCollectionDesktop extends StatelessWidget {
  const TemplatesCollectionDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: Dimens.size12,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimens.size16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLang.labelsTemplates.tr(),
                style: context.textTheme.titleLarge,
              ),
              FilledButton(
                onPressed: () => getViewModel<HomeViewModel>().onAddPressed(),
                child: Text(
                  AppLang.actionsAdd.tr(),
                  style: context.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: Theme(
            data: context.theme.copyWith(
              cardTheme: context.theme.cardTheme.copyWith(
                color: Colors.white,
                elevation: Dimens.size4,
              ),
            ),
            child: Card(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimens.size16,
                  vertical: Dimens.size16,
                ),
                itemBuilder: (context, index) {
                  return ItemDocumentCollection(
                    id: index.toString(),
                    title: "Proposal Template",
                  );
                },
                separatorBuilder: (context, index) {
                  return Dimens.spacing.vertical(Dimens.size16);
                },
                itemCount: 10,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
