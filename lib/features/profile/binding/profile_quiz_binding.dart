import 'package:get/get.dart';
import '../controller/profile_quiz_controller.dart';

class ProfileQuizBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileQuizController());
  }
}
