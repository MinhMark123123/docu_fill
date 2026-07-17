import 'dart:async';
import 'dart:io';

import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:docu_fill/core/core.dart';
import 'package:docu_fill/core/src/events.dart';
import 'package:docu_fill/features/src/home/view_model/fields_input_view_model.dart';
import 'package:docu_fill/route/src/routes_path.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:maac_mvvm_annotation/maac_mvvm_annotation.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

part 'export_history_view_model.g.dart';

@BindableViewModel()
class ExportHistoryViewModel extends BaseViewModel {
  final ExportHistoryRepository _exportHistoryRepository;
  final TemplateService _templateService;
  final ExportHistoryService _exportHistoryService;

  ExportHistoryViewModel({
    required ExportHistoryRepository exportHistoryRepository,
    required TemplateService templateService,
    required ExportHistoryService exportHistoryService,
  }) : _exportHistoryRepository = exportHistoryRepository,
       _templateService = templateService,
       _exportHistoryService = exportHistoryService;

  @Bind()
  late final _filteredHistories = List<ExportHistory>.empty().mtd(this);
  @Bind()
  late final _searchQuery = "".mtd(this);
  @Bind()
  late final _selectedStatus = Optional<ExportHistoryStatus>.empty().mtd(this);
  @Bind()
  late final _selectedTemplateName = Optional<String>.empty().mtd(this);
  @Bind()
  late final _availableTemplates = List<String>.empty().mtd(this);
  @Bind()
  late final _selectedHistory = Optional<ExportHistory>.empty().mtd(this);

  List<ExportHistory> _allHistories = [];
  StreamSubscription? _historySubscription;

  @override
  void onInitState() {
    super.onInitState();
    _historySubscription = _exportHistoryRepository
        .watchRecentHistories()
        .listen((list) {
          _allHistories = list;
          _updateAvailableTemplates(list);
          _filterHistories();
        });
  }

  @override
  void onDispose() {
    _historySubscription?.cancel();
    super.onDispose();
  }

  void updateSearchQuery(String query) {
    _searchQuery.postValue(query);
    _filterHistories();
  }

  void updateSelectedStatus(Optional<ExportHistoryStatus> status) {
    _selectedStatus.postValue(status);
    _filterHistories();
  }

  void updateSelectedTemplateName(Optional<String> name) {
    _selectedTemplateName.postValue(name);
    _filterHistories();
  }

  void selectHistory(ExportHistory history) {
    _selectedHistory.postValue(Optional.of(history));
  }

  void _updateAvailableTemplates(List<ExportHistory> list) {
    final names = <String>{};
    for (final history in list) {
      for (final template in history.templateSnapshots) {
        names.add(template.templateName);
      }
    }
    _availableTemplates.postValue(names.toList()..sort());
  }

  void _filterHistories() {
    final query = _searchQuery.data.trim().toLowerCase();
    final status = _selectedStatus.data.value;
    final templateName = _selectedTemplateName.data.value;

    final filtered =
        _allHistories.where((history) {
          if (status != null && history.status != status) return false;

          if (templateName != null) {
            final hasTemplate = history.templateSnapshots.any(
              (t) => t.templateName == templateName,
            );
            if (!hasTemplate) return false;
          }

          if (query.isNotEmpty) {
            final matchesFile = history.baseFileName.toLowerCase().contains(
              query,
            );
            final matchesDir = history.exportDirectory.toLowerCase().contains(
              query,
            );
            final matchesTemplate = history.templateSnapshots.any(
              (t) => t.templateName.toLowerCase().contains(query),
            );
            final matchesField = history.fieldValues.values.any(
              (v) => v.value != null && v.value!.toLowerCase().contains(query),
            );
            final matchesSingle = history.singleLineValues.values.any(
              (v) => v.value != null && v.value!.toLowerCase().contains(query),
            );

            if (!matchesFile &&
                !matchesDir &&
                !matchesTemplate &&
                !matchesField &&
                !matchesSingle) {
              return false;
            }
          }

          return true;
        }).toList();

    _filteredHistories.postValue(filtered);
  }

  Future<void> reExport(ExportHistory history) async {
    final dir = Directory(history.exportDirectory);
    if (!dir.existsSync()) {
      showSnackbar(
        AppLang.messagesExportDirNotFound.tr(args: [history.exportDirectory]),
      );
      return;
    }

    for (final template in history.templateSnapshots) {
      final file = File(template.pathTemplate);
      if (!file.existsSync()) {
        showSnackbar(
          AppLang.messagesTemplateFileNotFound.tr(
            args: [template.pathTemplate],
          ),
        );
        return;
      }
    }

    await loadingGuard(
      Future(() async {
        final composedUI = _templateService.groupFields(
          history.templateSnapshots,
        );
        final fieldValues = history.fieldValues.map(
          (key, entry) => MapEntry(key, entry.value),
        );
        final singleLineValues = history.singleLineValues.map(
          (key, entry) => MapEntry(key, entry.value),
        );
        final result = await _templateService.executeExport(
          templates: history.templateSnapshots,
          exportDirectory: history.exportDirectory,
          baseFileName: history.baseFileName,
          fieldKeys: fieldValues,
          singleLines: singleLineValues,
          composedUI: composedUI,
        );

        await _exportHistoryService.saveExportHistory(
          templates: history.templateSnapshots,
          exportDirectory: history.exportDirectory,
          baseFileName: history.baseFileName,
          fieldValues: fieldValues,
          singleLineValues: singleLineValues,
          result: result,
        );

        if (result.issues.isEmpty) {
          showSnackbar(AppLang.messagesReExportSuccess.tr());
        } else {
          final errorMsg = result.issues
              .map((e) => "${e.templateName}: ${e.message}")
              .join("\n");
          showSnackbar(AppLang.messagesReExportError.tr(args: [errorMsg]));
        }
      }),
    );
  }

  void restoreToForm(BuildContext context, ExportHistory history) {
    try {
      final fieldsInputVM = getViewModel<FieldsInputViewModel>();
      fieldsInputVM.restoreFromHistory(history);

      navigatePage(
        RoutesPath.home,
        type: NavigatePageType.replace,
        queryParameters: {'ids': history.templateIds.join(',')},
      );
    } catch (e) {
      showSnackbar("Error restoring form: $e");
    }
  }
}
