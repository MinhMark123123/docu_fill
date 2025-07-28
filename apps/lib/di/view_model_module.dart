import 'package:docu_fill/presenter/page.dart';
import 'package:docu_fill/presenter/src/home/view_model/home_view_model.dart';
import 'package:docu_fill/presenter/src/setting/view_model/setting_view_model.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

void setupViewModelModule() {
  registerViewModel(() => MainViewModel());
  registerViewModel(() => HomeViewModel());
  registerViewModel(() => SettingViewModel());
  registerViewModel(() => UploadViewModel());
  registerViewModel(() => ConfigureViewModel());
}
