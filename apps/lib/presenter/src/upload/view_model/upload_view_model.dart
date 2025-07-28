import 'package:docu_fill/core/core.dart';
import 'package:docu_fill/core/src/events.dart';
import 'package:docu_fill/presenter/page.dart';
import 'package:docu_fill/route/routers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:maac_mvvm_annotation/maac_mvvm_annotation.dart';
import 'package:maac_mvvm_with_get_it/maac_mvvm_with_get_it.dart';

part 'upload_view_model.g.dart';

@BindableViewModel()
class UploadViewModel extends BaseViewModel {
  @Bind()
  late final _filePicked = PlatformFile(name: "", size: 0).mtd(this);

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['.docx'],
    );
    if (result != null) {
      _filePicked.postValue(result.files.single);
    }
  }

  Future<void> continuePressed() async {
    if (_filePicked.data.path == null) return;
    navigatePage(
      RoutesPath.homeConfigure,
      type: NavigatePageType.replace,
      queryParameters: ConfigurePage.paramsQuery(path: _filePicked.data.path),
    );
  }
}
