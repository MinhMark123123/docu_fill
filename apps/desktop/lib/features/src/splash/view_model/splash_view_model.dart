import 'package:docu_fill/core/core.dart';
import 'package:docu_fill/core/src/events.dart';
import 'package:docu_fill/route/routers.dart';

class SplashViewModel extends BaseViewModel {
  @override
  void onInitState() {
    super.onInitState();
    _startWarmUp();
  }

  Future<void> _startWarmUp() async {
    // Wait for 1.8 seconds to allow the window size to settle,
    // dependencies to initialize, and showcase the premium splash animation.
    await Future.delayed(const Duration(milliseconds: 2800));

    // Smoothly replace the splash page with the home page
    navigatePage(RoutesPath.home, type: NavigatePageType.replace);
  }
}
