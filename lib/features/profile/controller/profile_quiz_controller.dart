import 'package:get/get.dart';
import '../../../core/services/quiz_service.dart';

class ProfileQuizController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxList<Map<String, dynamic>> kuisUmum = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> kuisMateri = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> riwayatKuis = <Map<String, dynamic>>[].obs;
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
        final payload = res['data'] is Map
            ? (res['data'] as Map).cast<String, dynamic>()
            : res;
        final umum = payload['kuis_umum'] ?? payload['umum'];
        final materi = payload['kuis_materi'] ?? payload['materi'];
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
        if (umum is! List && materi is! List && payload['data'] is List) {
          final all = (payload['data'] as List).cast<Map<String, dynamic>>();
          kuisUmum.assignAll(
            all.where(
              (item) => item['materi_id'] == null && item['materi'] == null,
            ),
          );
          kuisMateri.assignAll(
            all.where(
              (item) => item['materi_id'] != null || item['materi'] != null,
            ),
          );
        }
        final progress = payload['progress_map'];
        if (progress is Map) {
          progressMap.assignAll(progress.cast<String, dynamic>());
        } else {
          progressMap.clear();
        }
        final completed = payload['completed_materi_ids'];
        if (completed is List) {
          completedMateriIds.assignAll(
            completed
                .map((e) => int.tryParse(e.toString()) ?? 0)
                .where((e) => e > 0),
          );
        } else {
          completedMateriIds.clear();
        }
        await _fetchRiwayatKuis();
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchRiwayatKuis() async {
    try {
      final res = await QuizService.history(perPage: 100);
      final data = res['data'];
      if (data is List) {
        riwayatKuis.assignAll(data.cast<Map<String, dynamic>>());
      } else if (data is Map && data['data'] is List) {
        riwayatKuis.assignAll(
          (data['data'] as List).cast<Map<String, dynamic>>(),
        );
      } else {
        riwayatKuis.clear();
      }
    } catch (_) {
      riwayatKuis.clear();
    }
  }
}
