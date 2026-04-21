import 'package:docu_fill/data/src/services/template_service.dart';
import 'package:docu_fill/presenter/page.dart';
import 'package:docu_fill/presenter/src/home/view_model/fields_input_view_model.dart';
import 'package:docu_fill/presenter/src/home/view_model/home_view_model.dart';
import 'package:docu_fill/presenter/src/setting/view_model/setting_view_model.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

import 'app_get_it.dart';

void setupViewModelModule() {
  registerViewModel(() => MainViewModel());
  registerViewModel(
    () =>
        HomeViewModel(templateRepository: inject(), templateService: inject()),
  );
  registerViewModel(() => SettingViewModel(settingsRepository: inject()));
  registerViewModel(() => UploadViewModel());
  registerViewModel(() => ConfigureViewModel(templateRepository: inject()));
  sl.registerFactory<FieldsInputViewModel>(
    () => FieldsInputViewModel(
      templateRepository: inject(),
      templateService: inject(),
      dataExtractionService: inject(),
      geminiService: inject(),
    ),
  );
}
