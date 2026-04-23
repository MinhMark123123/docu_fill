import 'dart:io';

import 'package:docu_fill/const/enum/template_item_menu.dart';
import 'package:docu_fill/const/src/app_const.dart';
import 'package:docu_fill/const/src/app_lang.dart';
import 'package:docu_fill/core/core.dart';
import 'package:docu_fill/data/data.dart';
import 'package:docu_fill/presenter/src/configure/configure_page.dart';
import 'package:docu_fill/presenter/src/configure/view_model/configure_view_model.dart';
import 'package:docu_fill/route/src/routes_path.dart';
import 'package:docu_fill/utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:maac_mvvm_annotation/maac_mvvm_annotation.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

part 'home_view_model.g.dart';

typedef TemplateComposed = (List<int>, List<TemplateConfig>);

@BindableViewModel()
class HomeViewModel extends BaseViewModel {
  final TemplateRepository _templateRepository;
  final TemplateService _templateService;

  HomeViewModel({
    required TemplateRepository templateRepository,
    required TemplateService templateService,
  }) : _templateRepository = templateRepository,
       _templateService = templateService;

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

  void onTemplateSelected({required TemplateConfig data}) {
    if (_enableMultipleChoice.data) {
      _onMultipleTemplatesSelected(data);
    } else {
      _onSingleTemplateSelected(data);
    }
    navigatePage(
      RoutesPath.home,
      queryParameters: {"ids": _selectedTemplateIds.data.join(",")},
    );
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

  void onItemMenuSelected({
    required TemplateMenuItem itemMenu,
    required TemplateConfig item,
  }) {
    switch (itemMenu) {
      case TemplateMenuItem.edit:
        editTemplate(item: item);
        break;
      case TemplateMenuItem.delete:
        deleteTemplate(item);
        break;
      case TemplateMenuItem.exportSetting:
        exportSetting(item);
        break;
    }
  }

  Future<void> deleteTemplate(TemplateConfig item) async {
    await _templateService.deleteTemplate(item);
    await loadTemplates();
  }

  void setOnEnableMultipleChoice(bool value) {
    _enableMultipleChoice.postValue(value);
    if (value || _selectedTemplateIds.data.isEmpty) return;
    final singleSelectedItem = _selectedTemplateIds.data.first;
    _selectedTemplateIds.postValue([]);

    final data = _templates.data.firstWhere((t) => t.id == singleSelectedItem);
    onTemplateSelected(data: data);
  }

  void editTemplate({required TemplateConfig item}) {
    navigatePage(
      RoutesPath.homeConfigure,
      queryParameters: ConfigurePage.paramsQuery(
        path: item.pathTemplate,
        mode: ConfigureMode.edit,
        idEdit: item.id,
      ),
    );
  }

  Future<void> exportSetting(TemplateConfig item) async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result == null) return;

    final encodedArchive = await _templateService.createExportArchive(item);
    if (encodedArchive == null) return;

    final safeName = _templateService.getSafeFileName(item.templateName);
    final exportPath = [
      result,
      "$safeName${AppConst.settingFileExtension}",
    ].join(Platform.pathSeparator);

    await _templateService.saveExportedFile(encodedArchive, exportPath);
    showSnackbar(AppLang.messagesSettingExported.tr());
  }
}
