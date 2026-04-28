import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      final list = _extractList(res);
      if (list != null) {
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

  Map<String, dynamic> materiFromEntry(Map<String, dynamic> entry) {
    final direct = entry['materi'];
    if (direct is Map) return Map<String, dynamic>.from(direct);

    final data = entry['data'];
    if (data is Map && data['materi'] is Map) {
      return Map<String, dynamic>.from(data['materi'] as Map);
    }

    if (entry.containsKey('judul') ||
        entry.containsKey('cover_url') ||
        entry.containsKey('file_url')) {
      return entry;
    }

    return <String, dynamic>{};
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
      final materi = materiFromEntry(entry);
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
    final cover = found['cover_url']?.toString() ?? '';
    final pdfUrl = found['file_url']?.toString();

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

  List<Map<String, dynamic>>? _extractList(Map<String, dynamic> res) {
    final data = res['data'];
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    return null;
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
