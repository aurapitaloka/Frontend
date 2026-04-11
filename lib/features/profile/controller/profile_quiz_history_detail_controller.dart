import 'package:get/get.dart';
import '../../../core/services/quiz_service.dart';

class ProfileQuizHistoryDetailController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxMap<String, dynamic> hasil = <String, dynamic>{}.obs;

  late final int hasilId;

  @override
  void onInit() {
    super.onInit();
    hasilId = int.tryParse(Get.arguments?['hasil_id']?.toString() ?? '') ?? 0;
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    isLoading.value = true;
    error.value = '';
    try {
      final res = await QuizService.historyDetail(hasilId);
      if (res.containsKey('error')) {
        error.value = res['error'].toString();
      } else if (res['hasil'] is Map) {
        hasil.assignAll((res['hasil'] as Map).cast<String, dynamic>());
      } else {
        error.value = 'Data riwayat tidak ditemukan.';
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
