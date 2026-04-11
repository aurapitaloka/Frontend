import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/api_config.dart';
import '../../../routes/app_routes.dart';
import '../../../core/services/rak_buku_service.dart';

class RakBukuController extends GetxController {
  final RxList<Map<String, dynamic>> items = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    fetchItems();
  }

  Future<void> fetchItems({int page = 1, int perPage = 50}) async {
    isLoading.value = true;
    error.value = '';
    try {
      final res = await RakBukuService.list(page: page, perPage: perPage);
      if (res.containsKey('data') && res['data'] is List) {
        final list = (res['data'] as List).cast<Map<String, dynamic>>();
        items.assignAll(list);
      } else if (res.containsKey('data') && res['data'] is Map && res['data']['data'] is List) {
        final list = (res['data']['data'] as List).cast<Map<String, dynamic>>();
        items.assignAll(list);
      } else if (res.containsKey('error')) {
        error.value = res['error'].toString();
      } else {
        error.value = 'Tidak ada data';
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void openMateriFromVoice(String spoken) {
    final query = _extractMateriQuery(spoken);
    if (query.isEmpty) {
      Get.snackbar(
        'Tidak jelas',
        'Sebutkan judul materinya. Contoh: "buka materi pecahan".',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final normalizedQuery = _normalize(query);
    Map<String, dynamic>? found;

    for (final entry in items) {
      final materi = entry['materi'] as Map<String, dynamic>? ?? {};
      final title = materi['judul']?.toString() ?? '';
      if (title.isEmpty) continue;
      final normalizedTitle = _normalize(title);
      if (normalizedTitle.contains(normalizedQuery) ||
          normalizedQuery.contains(normalizedTitle)) {
        found = materi;
        break;
      }
      final words = normalizedQuery.split(' ').where((e) => e.isNotEmpty).toList();
      if (words.isNotEmpty && words.every(normalizedTitle.contains)) {
        found = materi;
        break;
      }
    }

    if (found == null) {
      Get.snackbar(
        'Materi tidak ditemukan',
        'Coba sebutkan judul yang lebih spesifik.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final title = found['judul']?.toString() ?? 'Materi';
    final subtitle = found['level']?['nama']?.toString() ?? '';
    final coverPath = found['cover_path']?.toString();
    final cover = ApiConfig.resolveStorageUrl(coverPath) ?? '';
    final filePath = found['file_path']?.toString();
    final pdfUrl = ApiConfig.resolveStorageUrl(filePath);

    Get.toNamed(
      AppRoutes.materialDetail,
      arguments: {
        'title': title,
        'subtitle': subtitle,
        'category': 'Rak Buku',
        'body': found['konten_teks']?.toString() ?? '',
        'coverImage': cover,
        'pdfUrl': pdfUrl,
        'materi_id': found['id'],
      },
    );
  }

  String _extractMateriQuery(String spoken) {
    var text = spoken.toLowerCase().trim();
    if (text.isEmpty) return '';

    final prefixes = [
      'buka materi',
      'baca materi',
      'lihat materi',
      'materi',
      'buka',
      'baca',
      'lihat',
    ];
    for (final p in prefixes) {
      if (text.startsWith(p)) {
        text = text.substring(p.length).trim();
        break;
      }
    }

    final leadingFillers = ['tentang', 'yang', 'ini'];
    for (final f in leadingFillers) {
      if (text.startsWith('$f ')) {
        text = text.substring(f.length).trim();
      }
    }

    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return text;
  }

  String _normalize(String text) {
    final lowered = text.toLowerCase();
    final cleaned = lowered.replaceAll(RegExp(r'[^a-z0-9 ]'), ' ');
    return cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
