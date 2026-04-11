import 'package:get/get.dart';
import '../controller/profile_quiz_detail_controller.dart';

class ProfileQuizDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileQuizDetailController());
  }
}
