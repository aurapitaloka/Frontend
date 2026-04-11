import 'package:get/get.dart';
import '../../../core/services/quiz_service.dart';

class ProfileQuizHistoryController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxList<Map<String, dynamic>> items = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
  }

  Future<void> fetchHistory({int perPage = 8}) async {
    isLoading.value = true;
    error.value = '';
    try {
      final res = await QuizService.history(perPage: perPage);
      if (res.containsKey('error')) {
        error.value = res['error'].toString();
      } else if (res['data'] is List) {
        items.assignAll((res['data'] as List).cast<Map<String, dynamic>>());
      } else if (res['data'] is Map && res['data']['data'] is List) {
        items.assignAll((res['data']['data'] as List).cast<Map<String, dynamic>>());
      } else {
        items.clear();
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
