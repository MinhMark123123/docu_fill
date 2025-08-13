import 'dart:async';
import 'dart:io';

import 'package:docu_fill/const/enum/template_item_menu.dart';
import 'package:docu_fill/core/core.dart';
import 'package:docu_fill/data/src/repositories/template/template_repository.dart';
import 'package:docu_fill/data/src/template_config.dart';
import 'package:docu_fill/route/src/routes_path.dart';
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
    loadTemplates();
    _composed.addSource(templates.asStream(), (data) {
      _composed.postValue((_composed.data.$1, data));
    });
    _composed.addSource(selectedTemplateIds.asStream(), (data) {
      _composed.postValue((data, _composed.data.$2));
    });
  }

  // Getter for multiple selected templates (if applicable)
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

      if ((currentSelectedId == -1 || !currentSelectionIsValid) &&
          currentTemplates.isNotEmpty) {
        _onSingleTemplateSelected(
          currentTemplates.first,
        ); // Or clear selection if preferred
      } else if (currentSelectedId != -1 && !currentSelectionIsValid) {
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

  void onTemplateSelected(TemplateConfig data) {
    if (_enableMultipleChoice.data) {
      _onMultipleTemplatesSelected(data);
    } else {
      _onSingleTemplateSelected(data);
    }
  }

  void _onSingleTemplateSelected(TemplateConfig data) {
    bool hasSelected = hasSelectedTemplates(data);
    if (hasSelected) return;
    _selectedTemplateIds.postValue([data.id]);
  }

  void _onMultipleTemplatesSelected(TemplateConfig data) {
    bool hasSelected = hasSelectedTemplates(data);
    if (hasSelected) {
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

  void onItemMenuSelected(
    TemplateMenuItem itemMenu, {
    required TemplateConfig item,
  }) {
    switch (itemMenu) {
      case TemplateMenuItem.edit:
        break;
      case TemplateMenuItem.delete:
        deleteTemplate(item);
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

  void setOnEnableMultipleChoice(bool value) {
    _enableMultipleChoice.postValue(value);
    if (!value && _selectedTemplateIds.data.length > 1) {
      _selectedTemplateIds.postValue([_selectedTemplateIds.data.first]);
    }
  }
}
