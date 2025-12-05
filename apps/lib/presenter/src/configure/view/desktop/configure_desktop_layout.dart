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

  ConfigureViewModel get configureViewModel =>
      getViewModel<ConfigureViewModel>();

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
              aspectRatio: 960 / 100,
              title: AppLang.labelsConfigureTemplateFields.tr(),
              subtitle: AppLang.messagesReviewAndConfigureFields.tr(),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimens.size16),
              child: confirmBox(context),
            ),
            configureTable(),
          ],
        ),
      ),
    );
  }

  Widget confirmBox(BuildContext context) {
    return StreamDataConsumer(
      streamData: configureViewModel.mode,
      builder: (context, mode) {
        switch (mode) {
          case ConfigureMode.addNew:
          case ConfigureMode.importSetting:
            return addNewConfirmBox(context);
          case ConfigureMode.edit:
            return editConfirmBox(context);
        }
      },
    );
  }

  Widget addNewConfirmBox(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppLang.labelsDetectedFields.tr(),
          style: context.textTheme.headlineSmall,
        ),
        Padding(
          padding: EdgeInsets.only(right: Dimens.size16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: Dimens.size16,
            children: [
              SizedBox(
                width: Dimens.size400,
                child: StreamDataConsumer(
                  streamData: configureViewModel.enableNameTemplate,
                  builder: (context, data) {
                    return Visibility(
                      visible: data,
                      replacement: SizedBox.shrink(),
                      child: TextField(
                        controller: configureViewModel.nameController,
                        onChanged:
                            (_) => configureViewModel.checkEnableConfirm(),
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
                streamData: configureViewModel.enableConfirm,
                builder: (context, data) {
                  return ElevatedButton(
                    onPressed:
                        data
                            ? () {
                              configureViewModel.confirm(context);
                            }
                            : null,
                    child: Text(AppLang.actionsConfirm.tr()),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget editConfirmBox(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppLang.labelsDetectedFields.tr(),
          style: context.textTheme.headlineSmall,
        ),
        Dimens.size16.wBox(),
        Padding(
          padding: EdgeInsets.only(right: Dimens.size16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: Dimens.size16,
            children: [
              SizedBox(
                width: Dimens.size400,
                child: StreamDataConsumer(
                  streamData: configureViewModel.enableNameTemplate,
                  builder: (context, data) {
                    return TextField(
                      enabled: false,
                      controller: configureViewModel.nameController,
                      decoration: InputDecoration(
                        hintText: AppLang.messagesEnterTemplateNameHint.tr(),
                        labelText: AppLang.labelsTemplateName.tr(),
                        border: OutlineInputBorder(),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () => configureViewModel.edit(context),
                child: Text(AppLang.actionsConfirm.tr()),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Expanded configureTable() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(left: Dimens.size16, right: Dimens.size32),
        child: StreamDataConsumer(
          streamData: configureViewModel.fieldsData,
          builder: (context, data) {
            return CustomScrollableTable(data: data);
          },
        ),
      ),
    );
  }
}
