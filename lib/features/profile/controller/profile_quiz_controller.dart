import 'package:get/get.dart';
import '../../../core/services/quiz_service.dart';

class ProfileQuizController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxList<Map<String, dynamic>> kuisUmum = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> kuisMateri = <Map<String, dynamic>>[].obs;
  final RxMap<String, dynamic> progressMap = <String, dynamic>{}.obs;
  final RxList<int> completedMateriIds = <int>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchKuis();
  }

  Future<void> fetchKuis() async {
    isLoading.value = true;
    error.value = '';
    try {
      final res = await QuizService.list();
      if (res.containsKey('error')) {
        error.value = res['error'].toString();
      } else {
        final umum = res['kuis_umum'];
        final materi = res['kuis_materi'];
        if (umum is List) {
          kuisUmum.assignAll(umum.cast<Map<String, dynamic>>());
        } else {
          kuisUmum.clear();
        }
        if (materi is List) {
          kuisMateri.assignAll(materi.cast<Map<String, dynamic>>());
        } else {
          kuisMateri.clear();
        }
        final progress = res['progress_map'];
        if (progress is Map) {
          progressMap.assignAll(progress.cast<String, dynamic>());
        } else {
          progressMap.clear();
        }
        final completed = res['completed_materi_ids'];
        if (completed is List) {
          completedMateriIds.assignAll(
            completed.map((e) => int.tryParse(e.toString()) ?? 0).where((e) => e > 0),
          );
        } else {
          completedMateriIds.clear();
        }
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
