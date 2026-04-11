import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/api_service.dart';

class PanduanController extends GetxController {
  final RxList<Map<String, dynamic>> panduanList = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    fetchPanduan();
  }

  Future<void> fetchPanduan() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final res = await ApiService.get('/panduan');
      final list = _extractList(res) ?? _extractListFromMessage(res);
      if (list != null) {
        panduanList.assignAll(list);
      } else {
        final status = res['_status_code'] as int?;
        if (status != 404) {
          errorMessage.value =
              res['message']?.toString() ??
              res['error']?.toString() ??
              'Gagal memuat panduan';
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
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

  List<Map<String, dynamic>>? _extractListFromMessage(
    Map<String, dynamic> response,
  ) {
    final message = response['message'];
    if (message is List) {
      return message.cast<Map<String, dynamic>>();
    }
    if (message is String && message.trim().startsWith('[')) {
      try {
        final decoded = jsonDecode(message);
        if (decoded is List) {
          return decoded.cast<Map<String, dynamic>>();
        }
      } catch (_) {}
    }
    return null;
  }
}
