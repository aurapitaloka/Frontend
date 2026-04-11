import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  bool _hasNavigated = false;

  @override
  void onInit() {
    super.onInit();
  }

  void startNavigation() {
    if (_hasNavigated) return;
    _hasNavigated = true;

    // Navigate to welcome screen after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (Get.currentRoute == AppRoutes.splash) {
        Get.offNamed(AppRoutes.welcome);
      }
    });
  }

  @override
  void onClose() {
    super.onClose();
  }
}
