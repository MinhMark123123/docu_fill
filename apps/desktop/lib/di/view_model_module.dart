import 'package:docu_fill/features/page.dart';
import 'package:docu_fill/features/src/home/view_model/fields_input_view_model.dart';
import 'package:docu_fill/features/src/home/view_model/home_view_model.dart';
import 'package:docu_fill/features/src/home/view_model/ai_result_selector_view_model.dart';
import 'package:docu_fill/features/src/setting/view_model/setting_view_model.dart';
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
  registerViewModel(
    () => FieldsInputViewModel(
      templateRepository: inject(),
      templateService: inject(),
      dataExtractionService: inject(),
      geminiService: inject(),
    ),
  );
  registerViewModel(() => LogHistoryViewModel());
  registerViewModel(() => LogDetailViewModel());
  registerViewModel(() => AiResultSelectorViewModel());
}
