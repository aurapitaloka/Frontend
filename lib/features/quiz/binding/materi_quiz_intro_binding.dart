import 'package:get/get.dart';
import '../controller/materi_quiz_intro_controller.dart';

class MateriQuizIntroBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MateriQuizIntroController());
  }
}
