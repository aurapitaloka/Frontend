import 'package:get/get.dart';
import '../controller/aac_controller.dart';

class AacBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AacController());
  }
}
