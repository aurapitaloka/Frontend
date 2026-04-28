import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/aac_service.dart';
import '../../../core/services/aac_tts_service.dart';

class AacController extends GetxController {
  final RxList<Map<String, dynamic>> items = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final ScrollController scrollController = ScrollController();

  final RxInt currentPage = 1.obs;
  final RxBool hasMore = true.obs;

  final AacTtsService _tts = createAacTtsService();

  @override
  void onInit() {
    super.onInit();
    fetchAac(reset: true);
  }

  @override
  void onClose() {
    scrollController.dispose();
    _tts.stop();
    super.onClose();
  }

  Future<void> fetchAac({bool reset = false}) async {
    if (isLoading.value) return;
    if (!hasMore.value && !reset) return;

    if (reset) {
      currentPage.value = 1;
      hasMore.value = true;
      items.clear();
      errorMessage.value = '';
    }

    isLoading.value = true;
    try {
      final res = await AacService.getAll(
        page: currentPage.value,
        perPage: 50,
      );
      final list = _extractList(res);
      if (list != null) {
        if (reset) {
          items.assignAll(list);
        } else {
          items.addAll(list);
        }
        if (list.isEmpty) {
          hasMore.value = false;
        } else {
          currentPage.value += 1;
        }
      } else {
        final status = res['_status_code'] as int?;
        if (status == 404) {
          errorMessage.value =
              'Endpoint AAC tidak ditemukan (404). Periksa route backend.';
        }
        if (status != 404) {
          errorMessage.value =
              res['message']?.toString() ??
              res['error']?.toString() ??
              'Gagal memuat AAC';
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshAac() => fetchAac(reset: true);

  Future<void> speakItem(Map<String, dynamic> item) async {
    final text = item['judul']?.toString() ?? '';
    if (text.isEmpty) return;
    await _tts.speak(text);
  }

  String? resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    return null;
  }

  List<Map<String, dynamic>>? _extractList(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    if (data is Map && data['data'] is List) {
      return (data['data'] as List).cast<Map<String, dynamic>>();
    }
    return null;
  }
}
