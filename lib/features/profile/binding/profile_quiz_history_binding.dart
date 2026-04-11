import 'package:get/get.dart';
import '../controller/profile_quiz_history_controller.dart';

class ProfileQuizHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileQuizHistoryController());
  }
}
