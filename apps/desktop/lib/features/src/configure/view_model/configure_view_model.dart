import 'dart:async';
import 'dart:io';

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
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:simple_loading_dialog/simple_loading_dialog.dart';

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
  final TemplateParsingService _parsingService;

  ConfigureViewModel({
    required TemplateRepository templateRepository,
    required TemplateParsingService parsingService,
  }) : _templateRepository = templateRepository,
       _parsingService = parsingService;

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
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [AppConst.settingFileExtension.replaceAll(".", "")],
      );

      if (result == null || result.files.single.path == null) return null;

      final bytes = await File(result.files.single.path!).readAsBytes();
      return _parsingService.findConfigInArchive(bytes);
    } catch (e) {
      debugPrint("Error picking template file: $e");
      showSnackbar("${AppLang.messagesImportConfigError.tr()}: $e");
    }
    return null;
  }

  Future<void> _loadImportSettingModeData() async {
    if (_pathFilePicked == null) return;
    try {
      final tempDir = await getTemporaryDirectory();
      _extractDir = Directory(extractDirPath(tempDir));

      final result = await _parsingService.parseTemplateArchive(
        File(_pathFilePicked!),
        _extractDir!,
      );

      if (result != null) {
        _applyImportedSettings(result.config, result.docPath);
      }
    } catch (e) {
      debugPrint("Error importing settings: $e");
    }
  }

  void _applyImportedSettings(TemplateConfig config, String docPath) {
    _nameController.text = config.templateName;
    final fields = config.fields.map((e) => TableRowData.fromTemplateField(e));
    _fieldsData.postValue(fields.toList());
    _pathFilePicked = docPath;
    checkEnableConfirm();
  }

  String extractDirPath(Directory tempDir) =>
      '${tempDir.path}${Platform.pathSeparator}import_docu_fill';

  Future<void> _loadNewTemplateData() async {
    if (_pathFilePicked == null) return;
    final file = File(_pathFilePicked!);
    final extension = p.extension(_pathFilePicked!).toLowerCase();

    try {
      String text = "";
      if (extension == '.docx') {
        text = await _parsingService.parseDocx(file);
      } else if (extension == '.xlsx' || extension == '.xls') {
        text = await _parsingService.parseExcel(file);
      }
      _extractFieldsFromText(text);
    } catch (e) {
      debugPrint("Error loading template: $e");
      if (e.toString().contains("Central Directory Record")) {
        showSnackbar(AppLang.messagesExcelUnsupportedFormat.tr());
      }
    }
  }

  void _extractFieldsFromText(String text) {
    final keys = _parsingService.extractFieldsFromText(text);
    final fields = keys.map((key) {
      return TableRowData(fieldKey: AppConst.composeKey(key: key));
    });
    _fieldsData.postValue(fields.toList());
  }

  TableRowData fieldOfKey(String key) {
    return _fieldsData.data.firstWhere((element) => element.fieldKey == key);
  }

  Future<void> updateField(
    String key,
    TableRowData Function(TableRowData) update,
  ) async {
    final index = fieldsData.data.indexWhere((e) => e.fieldKey == key);
    if (index == AppConst.commonUnknow) return;

    final current = _fieldsData.data[index];
    final updated = removeUselessInput(newData: update(current));
    _fieldsData.data[index] = updated;

    _fieldsData.postValue(List.from(_fieldsData.data));
    await checkEnableConfirm();
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

  Future<void> updateWidthImage(String key, String width) async {
    await updateField(key, (d) => _updateImageDimension(d, width, 0));
  }

  Future<void> updateHeightImage(String key, String height) async {
    await updateField(key, (d) => _updateImageDimension(d, height, 1));
  }

  Future<void> updateUnitImage(String key, ImageUnit? unit) async {
    await updateField(
      key,
      (d) => _updateImageDimension(d, unit?.value ?? "", 2),
    );
  }

  TableRowData _updateImageDimension(
    TableRowData data,
    String value,
    int index,
  ) {
    final parts = (data.additionalInfo ?? ";;${ImageUnit.cm.value}").split(";");
    if (parts.length < 3) return data;
    parts[index] = value;
    return data.copyWith(additionalInfo: parts.join(";"));
  }

  Future<void> saveConfigure(BuildContext context) async {
    await Future.delayed(Duration.zero);
    if (!context.mounted) return;

    final result = await loadingGuard(
      Future<bool>(() async {
        final path = await _prepareTemplateFile();
        if (path == null) return false;

        await _templateRepository.saveTemplate(
          generateTemplateConfig(name: _nameController.text, path: path),
        );
        return true;
      }),
    );

    if (_mode.data.isImportMode) await _extractDir?.delete(recursive: true);

    if (result) {
      showSnackbar(AppLang.messagesDocumentSuccessfullyCreate.tr());
      navigatePage(RoutesPath.home);
    }
  }

  Future<String?> _prepareTemplateFile() async {
    final uniqueName = DateTime.now().millisecondsSinceEpoch.toString();
    final extension = p.extension(_pathFilePicked!).toLowerCase();
    final newFileName = "$uniqueName$extension";

    String? sourcePath;
    if (_mode.data == ConfigureMode.addNew) {
      sourcePath = _pathFilePicked;
    } else if (_mode.data.isImportMode && _extractDir != null) {
      sourcePath = _findTemplateInExtractDir();
    }

    if (sourcePath == null) return null;

    return DocxUtils.saveDocxToAppDirectory(
      originalDocxPath: sourcePath,
      newFileName: newFileName,
      customDirectoryName: "templates",
    );
  }

  String? _findTemplateInExtractDir() {
    try {
      final file =
          _extractDir!.listSync().firstWhere(
                (f) => f is File && _parsingService.isTemplateDocument(f.path),
              )
              as File;
      return file.path;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveAsCopy(BuildContext context) async {
    await _handleTemplateAction(context, (current) async {
      final path = await _prepareCopyPath(current.pathTemplate);
      if (path == null) return false;
      await _templateRepository.saveTemplate(
        generateTemplateConfig(name: _nameController.text, path: path),
      );
      return true;
    });
  }

  Future<void> edit(BuildContext context) async {
    await _handleTemplateAction(context, (current) async {
      await _templateRepository.edit(
        current.id,
        generateTemplateConfig(
          name: _nameController.text,
          path: current.pathTemplate,
        ),
      );
      return true;
    });
  }

  Future<void> _handleTemplateAction(
    BuildContext context,
    Future<bool> Function(TemplateConfig) action,
  ) async {
    final accepted = await showConfirmDialog(context);
    if (!accepted || !context.mounted) return;

    final current = await _templateRepository.getTemplateById(_idEdit);
    if (current == null) return;

    final result = await showSimpleLoadingDialog(
      context: context,
      future: () => action(current),
    );

    if (result) {
      showSnackbar(AppLang.messagesDocumentSuccessfullyCreate.tr());
      navigatePage(RoutesPath.home);
    }
  }

  Future<String?> _prepareCopyPath(String originalPath) async {
    final uniqueName = DateTime.now().millisecondsSinceEpoch.toString();
    final extension = p.extension(originalPath).toLowerCase();
    return DocxUtils.saveDocxToAppDirectory(
      originalDocxPath: originalPath,
      newFileName: "$uniqueName$extension",
      customDirectoryName: "templates",
    );
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
