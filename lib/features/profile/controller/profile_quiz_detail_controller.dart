import 'package:get/get.dart';
import '../../../core/services/quiz_service.dart';

class ProfileQuizDetailController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString error = ''.obs;
  final RxMap<String, dynamic> kuis = <String, dynamic>{}.obs;

  final RxMap<int, int> jawaban = <int, int>{}.obs;
  final RxMap<int, String> jawabanTeks = <int, String>{}.obs;

  late final int kuisId;

  @override
  void onInit() {
    super.onInit();
    kuisId = int.tryParse(Get.arguments?['kuis_id']?.toString() ?? '') ?? 0;
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    isLoading.value = true;
    error.value = '';
    try {
      final res = await QuizService.detail(kuisId);
      if (res.containsKey('error')) {
        error.value = res['error'].toString();
      } else if (res['kuis'] is Map) {
        kuis.assignAll((res['kuis'] as Map).cast<String, dynamic>());
      } else {
        error.value = 'Data kuis tidak ditemukan.';
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void setJawaban(int pertanyaanId, int opsiId) {
    jawaban[pertanyaanId] = opsiId;
  }

  void setJawabanTeks(int pertanyaanId, String text) {
    jawabanTeks[pertanyaanId] = text;
  }

  Future<Map<String, dynamic>?> submit() async {
    isSubmitting.value = true;
    try {
      final payload = {
        'jawaban': jawaban.map((k, v) => MapEntry(k.toString(), v)),
        'jawaban_teks': jawabanTeks.map((k, v) => MapEntry(k.toString(), v)),
      };
      final res = await QuizService.submitByKuisId(kuisId, payload);
      if (res.containsKey('error')) {
        error.value = res['error'].toString();
        return null;
      }
      return res;
    } catch (e) {
      error.value = e.toString();
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }
}
