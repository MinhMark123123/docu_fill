import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:docu_fill/const/const.dart';
import 'package:docu_fill/core/core.dart';
import 'package:docu_fill/data/src/repositories/template/template_repository.dart';
import 'package:docu_fill/data/src/template_config.dart';
import 'package:docu_fill/presenter/src/configure/configure_page.dart';
import 'package:docu_fill/presenter/src/configure/view_model/configure_view_model.dart';
import 'package:docu_fill/presenter/src/home/widgets/desktop/input_page.dart';
import 'package:docu_fill/route/src/routes_path.dart';
import 'package:docu_fill/utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:maac_mvvm_annotation/maac_mvvm_annotation.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

part 'home_view_model.g.dart';

typedef TemplateComposed = (List<int>, List<TemplateConfig>);

@BindableViewModel()
class HomeViewModel extends BaseViewModel {
  final TemplateRepository _templateRepository;

  HomeViewModel({required TemplateRepository templateRepository})
    : _templateRepository = templateRepository;

  @Bind()
  late final _templates = <TemplateConfig>[].mtd(this);

  // Single source for selected IDs
  @Bind()
  late final _selectedTemplateIds = <int>[].mtd(this);
  @Bind()
  late final _enableMultipleChoice = false.mtd(this);
  @Bind()
  late final _composed = MediatorStreamData<(List<int>, List<TemplateConfig>)>(
    defaultValue: ([], []),
    viewModel: this,
  );

  @override
  void onInitState() {
    super.onInitState();
    _composed.addSource(templates.asStream(), (data) {
      _composed.postValue((_composed.data.$1, data));
    });
    _composed.addSource(selectedTemplateIds.asStream(), (data) {
      _composed.postValue((data, _composed.data.$2));
    });
  }

  @override
  void onResume() {
    super.onResume();
    loadTemplates();
  }

  List<TemplateConfig> get selectedTemplates {
    return _templates.data
        .where((t) => _selectedTemplateIds.data.contains(t.id))
        .toList();
  }

  Future<void> onAddPressed() async {
    await navigatePage(RoutesPath.homeUpload);
    await loadTemplates();
  }

  Future<void> loadTemplates() async {
    final newTemplates = await _templateRepository.getAllTemplates();
    _templates.postValue(newTemplates);
    _updateSelectionAfterLoading(newTemplates);
  }

  void _updateSelectionAfterLoading(List<TemplateConfig> currentTemplates) {
    if (!_enableMultipleChoice.data) {
      // If single selection mode and nothing selected, or selected item is gone
      final currentSelectedId =
          _selectedTemplateIds.data.isNotEmpty
              ? _selectedTemplateIds.data.first
              : -1;
      bool currentSelectionIsValid = currentTemplates.any(
        (t) => t.id == currentSelectedId,
      );
      if (currentSelectedId != -1 && !currentSelectionIsValid) {
        _selectedTemplateIds.postValue([]); // Clear invalid selection
      }
    } else {
      // Multiple choice: filter out IDs that no longer exist
      final validIds = currentTemplates.map((t) => t.id).toSet();
      final currentSelectedIds = _selectedTemplateIds.data.toList();
      currentSelectedIds.removeWhere((id) => !validIds.contains(id));
      _selectedTemplateIds.postValue(currentSelectedIds);
    }
  }

  void onTemplateSelected({
    required BuildContext context,
    required TemplateConfig data,
  }) {
    if (_enableMultipleChoice.data) {
      _onMultipleTemplatesSelected(data);
    } else {
      _onSingleTemplateSelected(data);
    }
    context.go(InputPage.pathCompose(_selectedTemplateIds.data));
  }

  void _onSingleTemplateSelected(TemplateConfig data) {
    bool hasSelected = hasSelectedTemplates(data);
    if (hasSelected) return;
    _selectedTemplateIds.postValue([data.id]);
  }

  void _onMultipleTemplatesSelected(TemplateConfig data) {
    bool hasSelected = hasSelectedTemplates(data);
    if (hasSelected && _selectedTemplateIds.data.length > 1) {
      final newList = List<int>.from(_selectedTemplateIds.data);
      newList.remove(data.id);
      _selectedTemplateIds.postValue(newList);
      return;
    }
    _selectedTemplateIds.postValue([..._selectedTemplateIds.data, data.id]);
  }

  bool hasSelectedTemplates(TemplateConfig data) {
    return _selectedTemplateIds.data.contains(data.id);
  }

  FutureOr<dynamic> doneExported() {
    _selectedTemplateIds.postValue([]);
  }

  void onItemMenuSelected({
    required BuildContext context,
    required TemplateMenuItem itemMenu,
    required TemplateConfig item,
  }) {
    switch (itemMenu) {
      case TemplateMenuItem.edit:
        editTemplate(context: context, item: item);
        break;
      case TemplateMenuItem.delete:
        deleteTemplate(item);
        break;
      case TemplateMenuItem.exportSetting:
        exportSetting(context, item);
        break;
    }
  }

  Future<void> deleteTemplate(TemplateConfig item) async {
    await _templateRepository.deleteTemplate(item.id);
    final file = File(item.pathTemplate);
    if (file.existsSync()) {
      await file.delete();
    }
    await loadTemplates();
  }

  void setOnEnableMultipleChoice(BuildContext context, bool value) {
    _enableMultipleChoice.postValue(value);
    if (value || _selectedTemplateIds.data.isEmpty) return;
    final singleSelectedItem = _selectedTemplateIds.data.first;
    _selectedTemplateIds.postValue([]);
    onTemplateSelected(
      context: context,
      data: _templates.data.firstWhere((t) => t.id == singleSelectedItem),
    );
  }

  void editTemplate({
    required BuildContext context,
    required TemplateConfig item,
  }) {
    navigatePage(
      RoutesPath.homeConfigure,
      queryParameters: ConfigurePage.paramsQuery(
        path: item.pathTemplate,
        mode: ConfigureMode.edit,
        idEdit: item.id,
      ),
    );
  }

  Future<void> exportSetting(BuildContext context, TemplateConfig item) async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result == null) return;
    // 1. Create the Archive object
    final archive = Archive();
    final safeName = (item.templateName).replaceAll(RegExp(r'[^\w\s]+'), '_');
    // 2. Add the .docx file to the archive
    final docxFile = File(item.pathTemplate);
    final docxBytes = await docxFile.readAsBytes();
    archive.addFile(
      ArchiveFile(AppConst.settingDocFileName, docxBytes.length, docxBytes),
    );

    // 3. Add the .json config to the archive
    final configMap = item.toJson();
    // IMPORTANT: Update the path in the config to match the relative path inside the zip
    // When importing, we will read this 'pathTemplate' to know which file in the zip is the template.

    final jsonString = jsonEncode(configMap);
    final jsonBytes = utf8.encode(jsonString);
    archive.addFile(
      ArchiveFile(AppConst.settingJsonFileName, jsonBytes.length, jsonBytes),
    );

    // 4. Encode the archive to Zip format
    final zipEncoder = ZipEncoder();
    final encodedArchive = zipEncoder.encode(archive);

    if (encodedArchive == null) return;

    // 5. Save the zip file to temp directory
    final exportPath = [
      result,
      "$safeName${AppConst.settingFileExtension}",
    ].join(Platform.pathSeparator);
    final exportFile = File(exportPath);
    await exportFile.writeAsBytes(encodedArchive);
    showSnackbar(AppLang.messagesSettingExported.tr());
  }
}
