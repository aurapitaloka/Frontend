import 'package:get/get.dart';
import '../controller/profile_notes_controller.dart';

class ProfileNotesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileNotesController());
  }
}
