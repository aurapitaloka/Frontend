import 'package:get/get.dart';
import '../controller/material_book_controller.dart';

class MaterialBookBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(MaterialBookController());
  }
}
