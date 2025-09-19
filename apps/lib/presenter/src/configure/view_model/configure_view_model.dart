import 'dart:async';
import 'dart:io';

import 'package:docu_fill/const/const.dart';
import 'package:docu_fill/core/core.dart';
import 'package:docu_fill/core/src/events.dart';
import 'package:docu_fill/data/data.dart';
import 'package:docu_fill/presenter/src/configure/model/table_row_data.dart';
import 'package:docu_fill/route/routers.dart';
import 'package:docu_fill/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:maac_mvvm_annotation/maac_mvvm_annotation.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';
import 'package:simple_loading_dialog/simple_loading_dialog.dart';

part 'configure_view_model.g.dart';

@BindableViewModel()
class ConfigureViewModel extends BaseViewModel {
  final TemplateRepository _templateRepository;

  ConfigureViewModel({required TemplateRepository templateRepository})
    : _templateRepository = templateRepository;

  @Bind()
  late final _fieldsData = <TableRowData>[].mtd(this);
  @Bind()
  late final _enableConfirm = false.mtd(this);
  @Bind()
  late final _enableNameTemplate = false.mtd(this);

  String? _pathFilePicked;
  final TextEditingController _nameController = TextEditingController();

  TextEditingController get nameController => _nameController;

  void setupPath({String? path}) => _pathFilePicked = path;

  @override
  void onInitState() {
    super.onInitState();
    loadDoc();
  }

  @override
  void onDispose() {
    _nameController.dispose();
    super.onDispose();
  }

  Future<void> loadDoc() async {
    if (_pathFilePicked == null) return;
    final f = File(_pathFilePicked!);
    final text = DocxUtils.docxToText(await f.readAsBytes());
    final regex = RegExp(AppConst.placeHolderRegex);
    final matches = regex.allMatches(text).map((e) => e.group(1)).toSet();
    final fields = matches.map((key) {
      return TableRowData(fieldKey: AppConst.composeKey(key: key!));
    });
    _fieldsData.postValue(fields.toList());
  }

  TableRowData fieldOfKey(String key) {
    return _fieldsData.data.firstWhere((element) => element.fieldKey == key);
  }

  Future<void> updateFieldData(String key, TableRowData? data) async {
    if (data == null) return;
    final index = fieldsData.data.indexWhere((e) => e.fieldKey == key);
    if (index == AppConst.commonUnknow) return;
    final newData = removeUselessInput(newData: data);
    _fieldsData.data[index] = newData;
  }

  Future<void> updateFieldName(String key, {required String fieldName}) async {
    updateFieldData(key, fieldOfKey(key).copyWith(fieldName: fieldName));
    await checkEnableConfirm();
  }

  Future<void> updateDefaultValue(
    String key, {
    required String defaultValue,
  }) async {
    updateFieldData(key, fieldOfKey(key).copyWith(defaultValue: defaultValue));
    await checkEnableConfirm();
  }

  Future<void> updateAdditionalInfo(
    String key, {
    required String additionalInfo,
  }) async {
    await updateFieldData(
      key,
      fieldOfKey(key).copyWith(additionalInfo: additionalInfo),
    );
    await checkEnableConfirm();
  }

  Future<void> updateOptions(
    String key, {
    required List<String> options,
  }) async {
    updateFieldData(key, fieldOfKey(key).copyWith(options: options));
    await checkEnableConfirm();
  }

  Future<void> updateIsRequired(String key, {bool? isRequired}) async {
    updateFieldData(key, fieldOfKey(key).copyWith(isRequired: isRequired));
    await checkEnableConfirm();
    notifyDataChanged();
  }

  Future<void> updateInputType(String key, {FieldType? inputType}) async {
    updateFieldData(key, fieldOfKey(key).copyWith(inputType: inputType));
    notifyDataChanged();
    await checkEnableConfirm();
  }

  Future<void> notifyDataChanged() async {
    _fieldsData.postValue(List.from(_fieldsData.data));
  }

  TableRowData removeUselessInput({required TableRowData newData}) {
    final raw = newData.copyWith();
    final inputType = raw.inputType;
    if (!inputType.isSelection) {
      raw.options = null;
    }
    if (inputType.isSelection) {
      raw.defaultValue = "";
    }
    return raw;
  }

  Future<void> checkEnableConfirm() async {
    bool hasNameEmpty = _fieldsData.data.any((e) {
      final name = e.fieldName;
      return name == null || name.isEmpty;
    });
    _enableNameTemplate.postValue(!hasNameEmpty);
    _enableConfirm.postValue(!hasNameEmpty && _nameController.text.isNotEmpty);
  }

  Future<void> confirm(BuildContext context) async {
    Completer<bool> accepted = Completer<bool>();
    showAppAlertDialog(
      title: AppLang.labelsConfigureTemplateFields.tr(),
      content: AppLang.messagesConfirmCreateDocument.tr(
        namedArgs: {'name': _nameController.text},
      ),
      actions: [
        DialogAction(
          isDestructive: true,
          title: AppLang.actionsCancel.tr(),
          onPressed: (dialogContext) {
            Navigator.of(dialogContext).pop();
            accepted.complete(false);
          },
        ),
        DialogAction(
          title: AppLang.actionsYes.tr(),
          onPressed: (dialogContext) {
            Navigator.of(dialogContext).pop();
            accepted.complete(true);
          },
        ),
      ],
    );
    final userAccepted = await accepted.future;
    if (!userAccepted || !context.mounted) return;
    await saveConfigure(context);
  }

  TemplateConfig generateTemplateConfig({
    required String name,
    required String path,
  }) {
    final fields = _fieldsData.data.map((e) => e.toTemplateField()).toList();
    return TemplateConfig(
      templateName: name,
      pathTemplate: path,
      version: DateTime.now().toString(),
      fields: fields,
    );
  }

  Future<void> updateWidthImage(
    String fieldKey, {
    required String widthImage,
  }) async {
    final currentRaw = fieldOfKey(fieldKey).additionalInfo;
    final splitter = currentRaw?.split(";");
    final widthString = double.tryParse(widthImage);
    if (widthString == null) return;
    if (splitter == null || splitter.isEmpty) {
      await updateAdditionalInfo(
        fieldKey,
        additionalInfo:
            "$widthString;;"
            "${ImageUnit.cm.value}",
      );
    } else {
      await updateAdditionalInfo(
        fieldKey,
        additionalInfo: [widthString, splitter[1], splitter[2]].join(";"),
      );
    }
  }

  Future<void> updateHeightImage(
    String fieldKey, {
    required String heightImage,
  }) async {
    final currentRaw = fieldOfKey(fieldKey).additionalInfo;
    final splitter = currentRaw?.split(";");
    final heightString = double.tryParse(heightImage);
    if (heightString == null) return;
    if (splitter == null || splitter.isEmpty) {
      await updateAdditionalInfo(
        fieldKey,
        additionalInfo: ";$heightString;${ImageUnit.cm.value}",
      );
    } else {
      await updateAdditionalInfo(
        fieldKey,
        additionalInfo: [splitter[0], heightString, splitter[2]].join(";"),
      );
    }
  }

  Future<void> updateUnitImage(String fieldKey, {ImageUnit? unitImage}) async {
    final currentRaw = fieldOfKey(fieldKey).additionalInfo;
    final splitter = currentRaw?.split(";");
    if (splitter == null || splitter.isEmpty) {
      await updateAdditionalInfo(
        fieldKey,
        additionalInfo: ";;${unitImage?.value}",
      );
    } else {
      await updateAdditionalInfo(
        fieldKey,
        additionalInfo: [splitter[0], splitter[1], unitImage?.value].join(";"),
      );
    }
  }

  Future<void> saveConfigure(BuildContext context) async {
    await Future.delayed(Duration.zero);
    if (!context.mounted) return;
    final result = await showSimpleLoadingDialog(
      context: context,
      future: () async {
        //step 1. save doc.x to new app dir file
        final uniqueName = DateTime.now().millisecondsSinceEpoch.toString();
        final newFileName = "$uniqueName.docx";
        final path = await DocxUtils.saveDocxToAppDirectory(
          originalDocxPath: _pathFilePicked!,
          newFileName: newFileName,
          customDirectoryName: "templates",
        );
        if (path == null) return false;
        //step 2. save template to db
        await _templateRepository.saveTemplate(
          generateTemplateConfig(name: _nameController.text, path: path),
        );
        return true;
      },
    );
    await Future.delayed(Duration.zero);
    if (result) {
      showSnackbar(AppLang.documentSuccessFullyCreate.tr());
      navigatePage(RoutesPath.home);
    }
  }
}
