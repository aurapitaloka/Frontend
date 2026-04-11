import 'package:get/get.dart';
import '../controller/material_detail_controller.dart';
import '../controller/pdf_reader_controller.dart';
import '../controller/reading_session_controller.dart';
import '../controller/assistive_controller.dart';

class MaterialDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ReadingSessionController());
    Get.put(PdfReaderController());
    Get.put(AssistiveController());
    Get.put(MaterialDetailController());
  }
}
