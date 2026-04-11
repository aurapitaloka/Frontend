import 'package:get/get.dart';
import '../controller/rak_buku_controller.dart';

class RakBukuBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RakBukuController());
  }
}
