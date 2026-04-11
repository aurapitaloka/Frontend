import 'package:get/get.dart';
import '../controller/profile_quiz_history_detail_controller.dart';

class ProfileQuizHistoryDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileQuizHistoryDetailController());
  }
}
