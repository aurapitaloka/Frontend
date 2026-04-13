import 'package:get/get.dart';
import '../../../core/services/quiz_service.dart';

class MateriQuizIntroController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxMap<String, dynamic> kuis = <String, dynamic>{}.obs;
  final RxBool noQuiz = false.obs;
  late final int materiId;
  late final String materiTitle;

  int get kuisId {
    final direct = kuis['id'] ?? kuis['kuis_id'];
    return int.tryParse(direct?.toString() ?? '') ?? 0;
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    materiId = int.tryParse(args['materi_id']?.toString() ?? '') ?? 0;
    materiTitle = args['materi_title']?.toString() ?? 'Materi';
    fetchQuiz();
  }

  Future<void> fetchQuiz() async {
    if (materiId == 0) {
      error.value = 'Materi tidak valid.';
      noQuiz.value = true;
      return;
    }
    isLoading.value = true;
    error.value = '';
    noQuiz.value = false;
    try {
      final res = await QuizService.materiQuiz(materiId);
      if (res.containsKey('error')) {
        error.value = res['error'].toString();
        noQuiz.value = true;
      } else if (res['kuis'] is Map) {
        kuis.assignAll((res['kuis'] as Map).cast<String, dynamic>());
      } else if (res['data'] is Map) {
        kuis.assignAll((res['data'] as Map).cast<String, dynamic>());
      } else if (res['id'] != null) {
        kuis.assignAll(res);
      } else {
        error.value = 'Kuis belum tersedia untuk materi ini.';
        noQuiz.value = true;
      }
    } catch (e) {
      error.value = e.toString();
      noQuiz.value = true;
    } finally {
      isLoading.value = false;
    }
  }
}
