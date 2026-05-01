import 'package:docu_fill/core/core.dart';
import 'package:docu_fill/core/src/events.dart' show ShowDialogEvent;
import 'package:docu_fill/features/src/configure/configure_desktop_layout.dart';
import 'package:docu_fill/features/src/configure/components/use_field_selection_dialog.dart';
import 'package:docu_fill/features/src/configure/view_model/configure_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';
import 'package:data/data.dart';

class ConfigurePage extends BaseView<ConfigureViewModel> {
  final String? path;
  final ConfigureMode? mode;
  final int? idEdit;

  const ConfigurePage({super.key, this.path, this.mode, this.idEdit});

  static Map<String, String?> paramsQuery({
    String? path,
    int? idEdit,
    required ConfigureMode mode,
  }) {
    return {
      'path': path,
      'mode': mode.valueString,
      'idEdit': idEdit.toString(),
    };
  }

  static String? queryPath({Map<String, String?>? stateQuery}) {
    if (stateQuery == null) return null;
    return stateQuery['path'];
  }

  static ConfigureMode? queryIsEditMode({Map<String, String?>? stateQuery}) {
    if (stateQuery == null) return null;
    return ConfigureMode.fromString(stateQuery['mode']);
  }

  static int? queryIdEdit({Map<String, String?>? stateQuery}) {
    if (stateQuery == null) return null;
    return int.tryParse(stateQuery['idEdit'] ?? '');
  }

  @override
  void awake(WrapperContext wrapperContext, ConfigureViewModel viewModel) {
    super.awake(wrapperContext, viewModel);
    viewModel.setupPath(
      path: path,
      mode: mode ?? ConfigureMode.addNew,
      idEdit: idEdit,
    );
  }

  @override
  Widget build(BuildContext context, viewModel) {
    return const ConfigureDesktopLayout();
  }

  @override
  AlertDialog alertDialogBuilder(
    ShowDialogEvent event,
    BuildContext dialogContext,
  ) {
    if (event is ShowUseSettingDialogEvent) {
      final itemList = event.listTemplate;
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppLang.labelsAllTemplates.tr()),
            IconButton(
              onPressed: () => Navigator.pop(dialogContext),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        content: SizedBox(
          width: 400,
          height: 300,
          child: ListView.builder(
            itemBuilder: (context, index) {
              final selectedOldTemplate = itemList[index];
              return ListTile(
                onTap: () {
                  Navigator.pop(dialogContext);
                  _showFieldSelectionDialog(dialogContext, selectedOldTemplate);
                },
                leading: const Icon(Icons.description_outlined),
                title: Text(selectedOldTemplate.templateName),
                subtitle: Text(
                  AppLang.messagesTemplateFieldCount.tr(
                    args: [selectedOldTemplate.fields.length.toString()],
                  ),
                ),
                trailing: const Icon(Icons.chevron_right, size: 18),
              );
            },
            itemCount: itemList.length,
          ),
        ),
      );
    }
    return super.alertDialogBuilder(event, dialogContext);
  }

  void _showFieldSelectionDialog(
    BuildContext context,
    TemplateConfig selectedOldTemplate,
  ) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => UseFieldSelectionDialog(
            currentFields:
                getViewModel<ConfigureViewModel>().fieldsData.data
                    .map((e) => e.toTemplateField())
                    .toList(),
            selectedOldTemplate: selectedOldTemplate,
            onApply: (selectedFields) {
              getViewModel<ConfigureViewModel>().applySelectedSettings(
                selectedFields,
                selectedOldTemplate.templateName,
              );
            },
          ),
    );
  }
}
