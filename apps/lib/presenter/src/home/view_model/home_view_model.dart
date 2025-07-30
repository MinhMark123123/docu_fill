import 'dart:async';

import 'package:docu_fill/core/core.dart';
import 'package:docu_fill/data/src/repositories/template/template_repository.dart';
import 'package:docu_fill/data/src/template_config.dart';
import 'package:docu_fill/route/src/routes_path.dart';
import 'package:maac_mvvm_annotation/maac_mvvm_annotation.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

part 'home_view_model.g.dart';

@BindableViewModel()
class HomeViewModel extends BaseViewModel {
  final TemplateRepository _templateRepository;

  HomeViewModel({required TemplateRepository templateRepository})
    : _templateRepository = templateRepository;

  @Bind()
  late final _templates = <TemplateConfig>[].mtd(this);
  @Bind()
  late final _idTemplateSelected = (-1).mtd(this);
  @Bind()
  late final _zipTemplatesAndSelected = (<TemplateConfig>[], -1).mtd(this);

  @override
  void onInitState() {
    super.onInitState();
    loadTemplates();
  }

  Future<void> onAddPressed() async {
    await navigatePage(RoutesPath.homeUpload);
    await loadTemplates();
  }

  Future<void> loadTemplates() async {
    final templates = await _templateRepository.getAllTemplates();
    _templates.postValue(templates);
    if (_idTemplateSelected.data == -1 && _templates.data.isNotEmpty) {
      onTemplateSelected(_templates.data.first);
    }
    _composeZipTemplatesAndSelected();
  }

  void onTemplateSelected(TemplateConfig data) {
    if (data.id == _idTemplateSelected.data) return;
    _idTemplateSelected.postValue(data.id);
    _composeZipTemplatesAndSelected();
  }

  void _composeZipTemplatesAndSelected() {
    _zipTemplatesAndSelected.postValue((
      _templates.data,
      _idTemplateSelected.data,
    ));
  }

  FutureOr<dynamic> doneExported() {
    _idTemplateSelected.postValue(-1);
    _composeZipTemplatesAndSelected();
  }
}
