import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/materi_service.dart';
import '../../../routes/app_routes.dart';

class MaterialBookController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxMap<String, dynamic> materi = <String, dynamic>{}.obs;
  final RxList<Map<String, dynamic>> babList = <Map<String, dynamic>>[].obs;

  late final int materiId;
  late final String fallbackTitle;
  late final String fallbackSubtitle;
  late final String fallbackCategory;
  late final String fallbackBody;
  late final String fallbackCoverImage;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    materiId = _parseInt(args['materi_id']) ?? 0;
    fallbackTitle = args['title']?.toString() ?? 'Materi';
    fallbackSubtitle = args['subtitle']?.toString() ?? '';
    fallbackCategory = args['category']?.toString() ?? 'Materi';
    fallbackBody = args['body']?.toString() ?? '';
    fallbackCoverImage = args['coverImage']?.toString() ?? '';
    _hydrateFallback(args);
    fetchDetail();
  }

  String get title =>
      materi['judul']?.toString().trim().isNotEmpty == true
          ? materi['judul'].toString()
          : fallbackTitle;

  String get subtitle {
    final level = materi['level'];
    final levelName = level is Map ? level['nama']?.toString() ?? '' : '';
    if (levelName.isNotEmpty) return levelName;
    return fallbackSubtitle;
  }

  String get subjectName {
    final mapel = materi['mata_pelajaran'];
    final mapelName = mapel is Map ? mapel['nama']?.toString() ?? '' : '';
    if (mapelName.isNotEmpty) return mapelName;
    return fallbackCategory;
  }

  String get description {
    final desc = materi['deskripsi']?.toString() ?? '';
    if (desc.trim().isNotEmpty) return desc.trim();
    return fallbackBody.trim();
  }

  String get coverImage {
    final raw =
        materi['cover_url']?.toString() ??
        materi['cover_path']?.toString() ??
        fallbackCoverImage;
    return raw;
  }

  String get category => subjectName;

  int get totalBab => babList.length;

  String get totalBabLabel => totalBab <= 1 ? '1 bab' : '$totalBab bab';

  Future<void> fetchDetail() async {
    if (materiId <= 0) return;
    isLoading.value = true;
    error.value = '';
    try {
      final res = await MateriService.getSingle(materiId);
      if (res.containsKey('error')) {
        error.value =
            res['message']?.toString() ?? res['error']?.toString() ?? '';
        return;
      }
      final detail = _extractMateriMap(res);
      if (detail.isEmpty) {
        error.value = 'Detail materi tidak ditemukan.';
        return;
      }
      materi.assignAll(detail);
      babList.assignAll(_extractBabList(detail));
      _ensureFallbackBab();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openFirstBab() async {
    if (babList.isEmpty) return;
    await openBab(0);
  }

  Future<void> continueReading() async {
    if (materiId <= 0 || babList.isEmpty) {
      await openFirstBab();
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final lastBabId = prefs.getInt('materi_${materiId}_last_bab_id') ?? 0;
    final fallbackIndex = prefs.getInt('materi_${materiId}_last_bab_index') ?? 0;

    var targetIndex = fallbackIndex.clamp(0, babList.length - 1);
    if (lastBabId > 0) {
      final index = babList.indexWhere((bab) => _parseInt(bab['id']) == lastBabId);
      if (index >= 0) targetIndex = index;
    }
    await openBab(targetIndex);
  }

  Future<void> openBab(int index) async {
    if (index < 0 || index >= babList.length) return;
    final bab = babList[index];
    final babId = _parseInt(bab['id']);
    final pdfUrl = _pickFirstString(bab, const [
      'file_url',
      'file_path',
      'pdf_url',
      'url',
    ]);
    final body = _pickFirstString(bab, const ['konten_teks', 'ringkasan', 'isi']);
    final babTitle =
        _pickFirstString(bab, const ['judul_bab', 'judul', 'nama']) ??
        'Bab ${index + 1}';

    if (materiId > 0) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('materi_${materiId}_last_bab_index', index);
      if (babId != null && babId > 0) {
        await prefs.setInt('materi_${materiId}_last_bab_id', babId);
      }
    }

    await Get.toNamed(
      AppRoutes.materialDetail,
      arguments: {
        'materi_id': materiId > 0 ? materiId : _parseInt(materi['id']),
        'bab_id': babId,
        'selected_bab_index': index,
        'bab_list': babList.toList(),
        'chapter_title': babTitle,
        'title': title,
        'subtitle': subtitle,
        'category': category,
        'coverImage': coverImage,
        'body': body ?? '',
        'pdfUrl': pdfUrl,
        'chapter_quiz': _extractQuizPayload(bab),
        'chapter_summary': _extractSummaryPayload(bab),
      },
    );
  }

  void _hydrateFallback(Map<String, dynamic> args) {
    materi.assignAll({
      'id': materiId > 0 ? materiId : args['id'],
      'judul': fallbackTitle,
      'deskripsi': args['deskripsi'] ?? fallbackBody,
      'level': args['level'],
      'cover_url': fallbackCoverImage,
      if (args['pdfUrl'] != null) 'file_url': args['pdfUrl'],
      if (args['body'] != null) 'konten_teks': args['body'],
    });

    final incomingBab = args['bab_list'];
    if (incomingBab is List) {
      babList.assignAll(
        incomingBab.whereType<Map>().map((e) => Map<String, dynamic>.from(e)),
      );
    }
    _ensureFallbackBab();
  }

  void _ensureFallbackBab() {
    if (babList.isNotEmpty) return;
    final fallbackPdf = _pickFirstString(materi, const ['file_url', 'file_path']);
    final fallbackText = _pickFirstString(materi, const ['konten_teks', 'deskripsi']);
    if ((fallbackPdf ?? '').isEmpty && (fallbackText ?? '').isEmpty) return;

    babList.assignAll([
      {
        'id': materi['id'],
        'judul_bab': 'Bab 1',
        'urutan': 1,
        'konten_teks': fallbackText ?? '',
        'file_url': fallbackPdf,
      },
    ]);
  }

  Map<String, dynamic> _extractMateriMap(Map<String, dynamic> res) {
    final data = res['data'];
    if (data is Map<String, dynamic>) {
      if (data['materi'] is Map<String, dynamic>) {
        return Map<String, dynamic>.from(data['materi'] as Map<String, dynamic>);
      }
      return Map<String, dynamic>.from(data);
    }
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      if (map['materi'] is Map) {
        return Map<String, dynamic>.from(map['materi'] as Map);
      }
      return map;
    }
    if (res['materi'] is Map) {
      return Map<String, dynamic>.from(res['materi'] as Map);
    }
    if (res['id'] != null || res['judul'] != null) {
      return Map<String, dynamic>.from(res);
    }
    return <String, dynamic>{};
  }

  List<Map<String, dynamic>> _extractBabList(Map<String, dynamic> detail) {
    final candidates = [
      detail['bab'],
      detail['materi_bab'],
      detail['chapters'],
      detail['detail_bab'],
    ];

    for (final candidate in candidates) {
      if (candidate is List) {
        final items = candidate
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
        if (items.isNotEmpty) {
          items.sort((a, b) {
            final orderA = _parseInt(a['urutan']) ?? 0;
            final orderB = _parseInt(b['urutan']) ?? 0;
            return orderA.compareTo(orderB);
          });
          return items;
        }
      }
    }
    return const <Map<String, dynamic>>[];
  }

  Map<String, dynamic>? _extractQuizPayload(Map<String, dynamic> bab) {
    final directQuiz = bab['kuis'];
    if (directQuiz is Map) return Map<String, dynamic>.from(directQuiz);

    final quizList = bab['kuis_list'] ?? bab['quiz_list'];
    if (quizList is List && quizList.isNotEmpty) {
      final first = quizList.first;
      if (first is Map) return Map<String, dynamic>.from(first);
    }

    final quizId = _parseInt(bab['kuis_id'] ?? bab['quiz_id']);
    if (quizId != null && quizId > 0) {
      return {'id': quizId, 'judul': bab['judul_kuis'] ?? 'Kuis Bab'};
    }
    return null;
  }

  Map<String, dynamic>? _extractSummaryPayload(Map<String, dynamic> bab) {
    final payload = <String, dynamic>{};
    const keys = <String>[
      'summary_title',
      'summary_short',
      'summary_key_points',
      'summary_keywords',
      'summary_memory_tip',
      'summary_example',
      'summary_generated_at',
    ];
    for (final key in keys) {
      if (bab[key] != null) payload[key] = bab[key];
    }
    return payload.isEmpty ? null : payload;
  }

  String? _pickFirstString(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key]?.toString();
      if (value != null && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  int? _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }
}
