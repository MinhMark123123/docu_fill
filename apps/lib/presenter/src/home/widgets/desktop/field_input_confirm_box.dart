import 'package:docu_fill/const/src/app_lang.dart';
import 'package:docu_fill/presenter/src/home/view_model/fields_input_view_model.dart';
import 'package:docu_fill/presenter/src/home/view_model/home_view_model.dart';
import 'package:docu_fill/ui/src/methodology/tokens/dimens.dart';
import 'package:docu_fill/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

class FieldInputConfirmBox extends StatelessWidget {
  const FieldInputConfirmBox({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamDataConsumer(
      streamData: getViewModel<FieldsInputViewModel>().enableEditNameDoc,
      builder: (context, data) {
        return Visibility(
          visible: data,
          child: Column(
            children: [
              Row(
                spacing: Dimens.size32,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: Dimens.size16,
                      mainAxisSize: MainAxisSize.min,
                      children: [folderPicker(), nameDocExported()],
                    ),
                  ),
                  VerticalDivider(),
                  exportButton(),
                ],
              ),
              Dimens.spacing.vertical(Dimens.size16),
              Divider(),
            ],
          ),
        );
      },
    );
  }

  Widget folderPicker() {
    return StreamDataConsumer(
      streamData: getViewModel<FieldsInputViewModel>().directoryExported,
      builder: (context, data) {
        return SizedBox(
          width: double.infinity,
          height: Dimens.size40,
          child: FilledButton(
            onPressed: () {
              getViewModel<FieldsInputViewModel>().pickFolder();
            },
            child: Text(
              data.isNotEmpty ? data : AppLang.messagesPickFolderToExport.tr(),
              style: context.textTheme.bodySmall?.copyWith(
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget nameDocExported() {
    return TextField(
      controller: getViewModel<FieldsInputViewModel>().nameDocExported,
      onChanged: (_) => getViewModel<FieldsInputViewModel>().checkValidate(),
      decoration: InputDecoration(
        hintText: AppLang.messagesNameTheDocumentExported.tr(),
      ),
    );
  }

  Widget exportButton() {
    return StreamDataConsumer(
      streamData: getViewModel<FieldsInputViewModel>().enableExported,
      builder: (context, data) {
        return ElevatedButton(
          onPressed:
              data
                  ? () => getViewModel<FieldsInputViewModel>()
                      .exported(context)
                      .then((_) => getViewModel<HomeViewModel>().doneExported())
                  : null,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimens.size40),
            child: Text(AppLang.actionsExportData.tr()),
          ),
        );
      },
    );
  }
}
