import 'package:docu_fill/core/core.dart';

class ConfigureViewModel extends BaseViewModel {
  String? _pathFilePicked;
  void setupPath({String? path}) => _pathFilePicked = path;
}
