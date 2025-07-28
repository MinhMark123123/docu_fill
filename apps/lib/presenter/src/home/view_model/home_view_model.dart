import 'package:docu_fill/core/core.dart';
import 'package:docu_fill/route/src/routes_path.dart';

class HomeViewModel extends BaseViewModel {
  Future<void> onAddPressed() async {
    await navigatePage(RoutesPath.homeUpload);
  }
}
