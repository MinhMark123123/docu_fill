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
    final matches = regex.allMatches(text);
    final fields = matches.map((match) {
      final key = match.group(1);
      return TableRowData(fieldKey: '''{{$key}}''');
    });
    _fieldsData.postValue(fields.toList());
  }

  Future<void> setValue(
    String key, {
    String? fieldName,
    FieldType? inputType,
    List<String>? options,
    bool? isRequired,
    String? defaultValue,
    String? additionalInfo,
  }) async {
    final index = _fieldsData.data.indexWhere(
      (element) => element.fieldKey == key,
    );
    var shouldUpdateUI = true;
    if (fieldName != null) {
      _fieldsData.data[index] = _fieldsData.data[index].copyWith(
        fieldName: fieldName,
      );
      shouldUpdateUI = false;
    }
    if (defaultValue != null) {
      _fieldsData.data[index] = _fieldsData.data[index].copyWith(
        fieldName: defaultValue,
      );
      shouldUpdateUI = false;
    }
    if (additionalInfo != null) {
      _fieldsData.data[index] = _fieldsData.data[index].copyWith(
        fieldName: additionalInfo,
      );
      shouldUpdateUI = false;
    }
    if (options != null) {
      _fieldsData.data[index] = _fieldsData.data[index].copyWith(
        options: options,
      );
      shouldUpdateUI = false;
    }
    if (shouldUpdateUI) {
      var newData = _fieldsData.data[index].copyWith(
        fieldName: fieldName,
        inputType: inputType,
        options: options,
        isRequired: isRequired,
        defaultValue: defaultValue,
        additionalInfo: additionalInfo,
      );
      bool hasInputType = inputType != null;
      newData = removeUselessInput(
        newData: newData,
        hasInputType: hasInputType,
      );
      _fieldsData.data[index] = newData;
      _fieldsData.postValue(List.from(_fieldsData.data));
    }
    await checkEnableConfirm();
  }

  TableRowData removeUselessInput({
    required TableRowData newData,
    required bool hasInputType,
  }) {
    final raw = newData.copyWith();
    final inputType = raw.inputType;
    if (!inputType.isSelection) {
      raw.options = null;
    }
    if (inputType.isSelection) {
      raw.defaultValue = "";
    }
    if (!inputType.isDateTime) {
      raw.additionalInfo = null;
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
