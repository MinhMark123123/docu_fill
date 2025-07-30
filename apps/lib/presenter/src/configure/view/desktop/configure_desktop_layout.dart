import 'package:docu_fill/const/src/app_lang.dart';
import 'package:docu_fill/presenter/src/configure/view/widgets/configure_table_fields.dart';
import 'package:docu_fill/presenter/src/configure/view_model/configure_view_model.dart';
import 'package:docu_fill/presenter/src/widgets/desktop_top_title.dart';
import 'package:docu_fill/ui/ui.dart';
import 'package:docu_fill/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class ConfigureDesktopLayout extends StatelessWidget {
  const ConfigureDesktopLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimens.size20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Dimens.size16,
          children: [
            DesktopTopTitle(
              aspectRatio: 960 / 126,
              title: AppLang.labelsConfigureTemplateFields.tr(),
              subtitle: AppLang.messagesReviewAndConfigureFields.tr(),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimens.size16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLang.labelsDetectedFields.tr(),
                    style: context.textTheme.headlineSmall,
                  ),
                  confirmButton(),
                ],
              ),
            ),
            configureTable(),
          ],
        ),
      ),
    );
  }

  Widget confirmButton() {
    return Padding(
      padding: EdgeInsets.only(right: Dimens.size16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: Dimens.size16,
        children: [
          SizedBox(
            width: Dimens.size400,
            child: StreamDataConsumer(
              streamData: getViewModel<ConfigureViewModel>().enableNameTemplate,
              builder: (context, data) {
                return Visibility(
                  visible: data,
                  replacement: SizedBox.shrink(),
                  child: TextField(
                    controller:
                        getViewModel<ConfigureViewModel>().nameController,
                    onChanged:
                        (_) =>
                            getViewModel<ConfigureViewModel>()
                                .checkEnableConfirm(),
                    decoration: InputDecoration(
                      hintText: AppLang.messagesEnterTemplateNameHint.tr(),
                      labelText: AppLang.labelsTemplateName.tr(),
                      border: OutlineInputBorder(),
                    ),
                  ),
                );
              },
            ),
          ),
          StreamDataConsumer(
            streamData: getViewModel<ConfigureViewModel>().enableConfirm,
            builder: (context, data) {
              return ElevatedButton(
                onPressed:
                    data
                        ? () {
                          getViewModel<ConfigureViewModel>().confirm(context);
                        }
                        : null,
                child: Text(AppLang.actionsConfirm.tr()),
              );
            },
          ),
        ],
      ),
    );
  }

  Expanded configureTable() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(left: Dimens.size16, right: Dimens.size32),
        child: StreamDataConsumer(
          streamData: getViewModel<ConfigureViewModel>().fieldsData,
          builder: (context, data) {
            return CustomScrollableTable(data: data);
          },
        ),
      ),
    );
  }
}
