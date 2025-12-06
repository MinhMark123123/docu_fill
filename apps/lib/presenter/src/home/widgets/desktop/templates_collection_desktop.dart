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
    return Padding(
      padding: EdgeInsets.only(top: Dimens.size16),
      child: Column(
        spacing: Dimens.size12,
        children: [header(context), templateBox(context), addNew(context)],
      ),
    );
  }

  Expanded templateBox(BuildContext context) {
    return Expanded(
      child: Theme(
        data: context.theme.copyWith(
          cardTheme: context.theme.cardTheme.copyWith(
            color: Colors.white,
            elevation: Dimens.size4,
          ),
        ),
        child: templateList(),
      ),
    );
  }

  Widget templateList() {
    final viewModel = getViewModel<HomeViewModel>();
    return StreamDataConsumer(
      streamData: viewModel.composed,
      builder: (context, value) {
        final selectedIds = value.$1;
        final templates = value.$2;
        return ListView.separated(
          padding: EdgeInsets.symmetric(
            vertical: Dimens.size16,
            horizontal: Dimens.size8,
          ),
          itemBuilder: (context, index) {
            final isSelected = selectedIds.contains(templates[index].id);
            return ItemDocumentCollection(
              isSelected: isSelected,
              id: index.toString(),
              title: templates[index].templateName,
              onItemPressed: () {
                viewModel.onTemplateSelected(
                  context: context,
                  data: templates[index],
                );
              },
              onOptionsMenuPress: (itemMenu) {
                viewModel.onItemMenuSelected(
                  context: context,
                  itemMenu: itemMenu,
                  item: templates[index],
                );
              },
            );
          },
          separatorBuilder: (context, index) {
            return Dimens.spacing.vertical(Dimens.size4);
          },
          itemCount: templates.length,
        );
      },
    );
  }

  Padding header(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Dimens.size16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: Dimens.size8),
            child: Text(
              AppLang.labelsTemplates.tr(),
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          multipleChoice(context),
        ],
      ),
    );
  }

  Widget multipleChoice(BuildContext context) {
    return StreamDataConsumer(
      streamData: getViewModel<HomeViewModel>().enableMultipleChoice,
      builder: (context, data) {
        final title =
            data == false
                ? AppLang.labelsSingle.tr()
                : AppLang.labelsMultiple.tr();
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: data,
              onChanged: (value) {
                getViewModel<HomeViewModel>().setOnEnableMultipleChoice(
                  context,
                  value,
                );
              },
            ),
            Text(
              title,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.appColors?.bodyTextColor,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget addNew(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: Dimens.size12,
        horizontal: Dimens.size8,
      ),
      width: double.infinity,
      child: FilledButton(
        onPressed: () => getViewModel<HomeViewModel>().onAddPressed(),
        child: Padding(
          padding: EdgeInsets.all(Dimens.size8),
          child: Text(
            AppLang.actionsAdd.tr(),
            style: context.textTheme.bodySmall,
          ),
        ),
      ),
    );
  }
}
