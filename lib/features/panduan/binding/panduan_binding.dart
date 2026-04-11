import 'package:get/get.dart';
import '../controller/panduan_controller.dart';

class PanduanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PanduanController());
  }
}
