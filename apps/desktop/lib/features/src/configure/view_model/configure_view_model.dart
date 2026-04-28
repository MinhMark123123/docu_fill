import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:docu_fill/core/core.dart';
import 'package:docu_fill/core/src/events.dart';
import 'package:docu_fill/features/src/configure/model/table_row_data.dart';
import 'package:docu_fill/route/routers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:maac_mvvm_annotation/maac_mvvm_annotation.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_loading_dialog/simple_loading_dialog.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

part 'configure_view_model.g.dart';

enum ConfigureMode {
  addNew,
  edit,
  importSetting;

  String get valueString => toString().split('.').last;

  static ConfigureMode? fromString(String? value) {
    if (value == null) return null;
    return ConfigureMode.values.firstWhere(
      (e) => e.valueString == value,
      orElse: () => ConfigureMode.addNew,
    );
  }

  bool get isImportMode => this == ConfigureMode.importSetting;

  bool get isEdit => this == ConfigureMode.edit;

  bool get isAddNew => this == ConfigureMode.addNew;
}

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
  @Bind()
  late final _mode = ConfigureMode.addNew.mtd(this);

  int _idEdit = -1;
  Directory? _extractDir;

  String? _pathFilePicked;
  final TextEditingController _nameController = TextEditingController();

  TextEditingController get nameController => _nameController;

  void setupPath({String? path, required ConfigureMode mode, int? idEdit}) {
    _pathFilePicked = path;
    _mode.postValue(mode);
    _idEdit = idEdit ?? -1;
  }

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
    switch (_mode.data) {
      case ConfigureMode.addNew:
        await _loadNewTemplateData();
        break;
      case ConfigureMode.edit:
        await _loadEditModeData();
      case ConfigureMode.importSetting:
        await _loadImportSettingModeData();
    }
  }

  Future<void> _loadEditModeData() async {
    if (_pathFilePicked == null || _idEdit == -1) return;
    final template = await _templateRepository.getTemplateById(_idEdit);
    if (template == null) return;
    final fields = template.fields.map(
      (e) => TableRowData(
        fieldKey: e.key,
        inputType: e.type,
        fieldName: e.label,
        options: e.options,
        isRequired: e.required,
        defaultValue: e.defaultValue,
        additionalInfo: e.additionalInfo,
        section: e.section,
        description: e.description,
      ),
    );
    _fieldsData.postValue(fields.toList());
    _nameController.text = template.templateName;
    checkEnableConfirm();
  }

  void useSetting(BuildContext context, TemplateConfig template) {
    final fieldsTemplate = template.fields.map(
      (e) => TableRowData(
        fieldKey: e.key,
        inputType: e.type,
        fieldName: e.label,
        options: e.options,
        isRequired: e.required,
        defaultValue: e.defaultValue,
        additionalInfo: e.additionalInfo,
        section: e.section,
        description: e.description,
      ),
    );
    final fieldsClone = List<TableRowData>.from(_fieldsData.data);
    for (var settingItem in fieldsTemplate) {
      final indexKey = fieldsClone.indexWhere(
        (e) => e.fieldKey == settingItem.fieldKey,
      );
      if (indexKey == AppConst.commonUnknow) continue;
      fieldsClone[indexKey] = settingItem;
    }
    _fieldsData.postValue(fieldsClone);
    _nameController.text = template.templateName;
    checkEnableConfirm();
  }

  void applySelectedSettings(
    List<TemplateField> selectedFields,
    String oldTemplateName,
  ) {
    final currentFields = List<TableRowData>.from(_fieldsData.data);

    for (var selected in selectedFields) {
      final index = currentFields.indexWhere((f) => f.fieldKey == selected.key);
      if (index != -1) {
        currentFields[index] = TableRowData(
          fieldKey: selected.key,
          fieldName: selected.label,
          inputType: selected.type,
          options: selected.options,
          isRequired: selected.required,
          defaultValue: selected.defaultValue,
          additionalInfo: selected.additionalInfo,
          section: selected.section,
          description: selected.description,
        );
      }
    }

    _fieldsData.postValue(currentFields);

    if (_nameController.text.isEmpty) {
      _nameController.text = oldTemplateName;
    }

    checkEnableConfirm();
  }

  Future<TemplateConfig?> pickAndParseTemplateFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [AppConst.settingFileExtension.replaceAll(".", "")],
      );

      if (result == null || result.files.single.path == null) return null;

      final bytes = await File(result.files.single.path!).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      for (final file in archive) {
        if (file.isFile && file.name.endsWith(AppConst.settingJsonFileName)) {
          final jsonString = utf8.decode(file.content as List<int>);
          final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
          return TemplateConfig.fromJson(jsonMap);
        }
      }
    } catch (e) {
      debugPrint("Error picking template file: $e");
      showSnackbar(
        "${AppLang.messagesImportConfigError.tr()}: ${e.toString()}",
      );
    }
    return null;
  }

  Future<void> _loadImportSettingModeData() async {
    if (_pathFilePicked == null) return;
    final f = File(_pathFilePicked!);
    try {
      final bytes = await f.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      final tempDir = await getTemporaryDirectory();
      _extractDir = Directory(extractDirPath(tempDir));
      if (_extractDir?.existsSync() ?? false) {
        _extractDir?.deleteSync(recursive: true);
      }
      await _extractDir!.create(recursive: true);

      File? configFile;
      File? docxFile;

      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          final extractedFile = File(
            '${_extractDir!.path}${Platform.pathSeparator}$filename',
          );
          await extractedFile.writeAsBytes(data);

          if (filename.endsWith(AppConst.settingJsonFileName)) {
            configFile = extractedFile;
          } else if (filename.endsWith(AppConst.settingDocFileName) ||
              filename.endsWith('.docx') ||
              filename.endsWith('.xlsx')) {
            docxFile = extractedFile;
          }
        }
      }

      if (configFile != null && docxFile != null) {
        final jsonString = await configFile.readAsString();
        final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
        final templateConfig = TemplateConfig.fromJson(jsonMap);

        _nameController.text = templateConfig.templateName;

        final fields = templateConfig.fields.map(
          (e) => TableRowData(
            fieldKey: e.key,
            inputType: e.type,
            fieldName: e.label,
            options: e.options,
            isRequired: e.required,
            defaultValue: e.defaultValue,
            additionalInfo: e.additionalInfo,
            section: e.section,
            description: e.description,
          ),
        );
        _fieldsData.postValue(fields.toList());
        _pathFilePicked = docxFile.path;
        await checkEnableConfirm();
      }
    } catch (e) {
      debugPrint("Error importing settings: $e");
    }
  }

  String extractDirPath(Directory tempDir) =>
      '${tempDir.path}${Platform.pathSeparator}import_docu_fill';

  Future<void> _loadNewTemplateData() async {
    if (_pathFilePicked == null) return;
    final extension = _pathFilePicked!.split('.').last.toLowerCase();

    if (extension == 'docx') {
      await _loadDocxTemplateData();
    } else if (extension == 'xlsx' || extension == 'xls') {
      await _loadExcelTemplateData();
    }
  }

  Future<void> _loadDocxTemplateData() async {
    try {
      final f = File(_pathFilePicked!);
      final bytes = await f.readAsBytes();
      final text = DocxUtils.docxToText(bytes);
      _extractFieldsFromText(text);
    } catch (e) {
      debugPrint("Error loading Word template: $e");
      if (e.toString().contains("Central Directory Record")) {
        showSnackbar(AppLang.messagesExcelUnsupportedFormat.tr());
      }
    }
  }

  Future<void> _loadExcelTemplateData() async {
    try {
      final f = File(_pathFilePicked!);
      final bytes = await f.readAsBytes();
      final decoder = SpreadsheetDecoder.decodeBytes(bytes);
      final StringBuffer buffer = StringBuffer();

      for (var table in decoder.tables.keys) {
        final sheet = decoder.tables[table];
        if (sheet == null) continue;
        for (var row in sheet.rows) {
          final rowData = row.map((cell) => cell?.toString() ?? '').join(' ');
          buffer.writeln(rowData);
        }
      }
      _extractFieldsFromText(buffer.toString());
    } catch (e) {
      debugPrint('Error loading Excel template: $e');
      if (e.toString().contains("Central Directory Record")) {
        showSnackbar(AppLang.messagesExcelUnsupportedFormat.tr());
      }
    }
  }

  void _extractFieldsFromText(String text) {
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
    await notifyDataChanged();
  }

  Future<void> updateFieldName(String key, {required String fieldName}) async {
    await updateFieldData(key, fieldOfKey(key).copyWith(fieldName: fieldName));
    await checkEnableConfirm();
  }

  Future<void> updateDefaultValue(
    String key, {
    required String defaultValue,
  }) async {
    await updateFieldData(
      key,
      fieldOfKey(key).copyWith(defaultValue: defaultValue),
    );
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
    await updateFieldData(key, fieldOfKey(key).copyWith(options: options));
    await checkEnableConfirm();
  }

  Future<void> updateIsRequired(String key, {bool? isRequired}) async {
    await updateFieldData(
      key,
      fieldOfKey(key).copyWith(isRequired: isRequired),
    );
    await checkEnableConfirm();
  }

  Future<void> updateInputType(String key, {FieldType? inputType}) async {
    await updateFieldData(key, fieldOfKey(key).copyWith(inputType: inputType));
    await checkEnableConfirm();
  }

  Future<void> updateSection(String key, {String? section}) async {
    await updateFieldData(key, fieldOfKey(key).copyWith(section: section));
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
    final userAccepted = await showConfirmDialog(context);
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
        final uniqueName = DateTime.now().millisecondsSinceEpoch.toString();
        final extension = _pathFilePicked!.split('.').last.toLowerCase();
        final newFileName = "$uniqueName.$extension";
        String? path;
        if (_mode.data == ConfigureMode.addNew) {
          path = await DocxUtils.saveDocxToAppDirectory(
            originalDocxPath: _pathFilePicked!,
            newFileName: newFileName,
            customDirectoryName: "templates",
          );
        } else if (_mode.data.isImportMode && _extractDir != null) {
          final extractedFile =
              Directory(_extractDir!.path).listSync().firstWhere(
                    (file) =>
                        file is File &&
                        (file.path.endsWith('.docx') ||
                            file.path.endsWith('.xlsx') ||
                            file.path.endsWith(AppConst.settingDocFileName)),
                  )
                  as File;

          path = await DocxUtils.saveDocxToAppDirectory(
            originalDocxPath: extractedFile.path,
            newFileName: newFileName,
            customDirectoryName: "templates",
          );
        }
        if (path == null) return false;
        await _templateRepository.saveTemplate(
          generateTemplateConfig(name: _nameController.text, path: path),
        );
        return true;
      },
    );
    if (_mode.data.isImportMode) {
      await _extractDir?.delete(recursive: true);
    }
    await Future.delayed(Duration.zero);
    if (result) {
      showSnackbar(AppLang.messagesDocumentSuccessfullyCreate.tr());
      navigatePage(RoutesPath.home);
    }
  }

  Future<void> saveAsCopy(BuildContext context) async {
    final userAccepted = await showConfirmDialog(context);
    if (!userAccepted || !context.mounted) return;
    await Future.delayed(Duration.zero);
    final current = await _templateRepository.getTemplateById(_idEdit);
    if (!context.mounted && current == null) return;
    final result = await showSimpleLoadingDialog(
      context: context,
      future: () async {
        final uniqueName = DateTime.now().millisecondsSinceEpoch.toString();
        final extension = current!.pathTemplate.split('.').last.toLowerCase();
        final newFileName = "$uniqueName.$extension";

        final path = await DocxUtils.saveDocxToAppDirectory(
          originalDocxPath: current.pathTemplate,
          newFileName: newFileName,
          customDirectoryName: "templates",
        );

        if (path == null) return false;
        await _templateRepository.saveTemplate(
          generateTemplateConfig(name: _nameController.text, path: path),
        );
        return true;
      },
    );
    await Future.delayed(Duration.zero);
    if (result) {
      showSnackbar(AppLang.messagesDocumentSuccessfullyCreate.tr());
      navigatePage(RoutesPath.home);
    }
  }

  Future<void> edit(BuildContext context) async {
    final userAccepted = await showConfirmDialog(context);
    if (!userAccepted || !context.mounted) return;
    await Future.delayed(Duration.zero);
    final current = await _templateRepository.getTemplateById(_idEdit);
    if (!context.mounted && current == null) return;
    final result = await showSimpleLoadingDialog(
      context: context,
      future: () async {
        await _templateRepository.edit(
          current!.id,
          generateTemplateConfig(
            name: _nameController.text,
            path: current.pathTemplate,
          ),
        );
        return true;
      },
    );
    await Future.delayed(Duration.zero);
    if (result) {
      showSnackbar(AppLang.messagesDocumentSuccessfullyCreate.tr());
      navigatePage(RoutesPath.home);
    }
  }

  Future<bool> showConfirmDialog(BuildContext context) async {
    Completer<bool> accepted = Completer<bool>();
    final labelKey = switch (_mode.data) {
      ConfigureMode.addNew => AppLang.messagesConfirmCreateDocument,
      ConfigureMode.edit => AppLang.messagesConfirmEditDocument,
      _ => AppLang.messagesConfirmCreateDocument,
    };
    showAppAlertDialog(
      title: AppLang.labelsConfigureTemplateFields.tr(),
      content: labelKey.tr(namedArgs: {'name': _nameController.text}),
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
    return accepted.future;
  }

  Future<void> openSettingOptions(BuildContext context) async {
    final listTemplate = await _templateRepository.getAllTemplates();
    showAppRawEventAlertDialog(
      event: ShowUseSettingDialogEvent(listTemplate: listTemplate),
    );
  }
}

class ShowUseSettingDialogEvent extends ShowDialogEvent<void> {
  final List<TemplateConfig> listTemplate;

  ShowUseSettingDialogEvent({
    super.actions,
    required this.listTemplate,
    super.content,
    super.onCompleted,
    super.title,
  });

  @override
  ShowUseSettingDialogEvent copyWith({
    String? title,
    String? content,
    List<DialogAction>? actions,
    List<TemplateConfig>? listTemplate,
    List<String>? options,
    Function(void)? onCompleted,
  }) {
    return ShowUseSettingDialogEvent(
      listTemplate: listTemplate ?? this.listTemplate,
      title: title ?? this.title,
      content: content ?? this.content,
      actions: actions ?? this.actions,
      onCompleted: onCompleted ?? this.onCompleted,
    );
  }
}
