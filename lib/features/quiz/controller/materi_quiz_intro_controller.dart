import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/controllers/voice_command_controller.dart';
import '../../../core/services/voice_guide_service.dart';
import '../../../core/services/quiz_service.dart';
import '../../../routes/app_routes.dart';

class MateriQuizIntroController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxMap<String, dynamic> kuis = <String, dynamic>{}.obs;
  final RxList<Map<String, dynamic>> kuisList = <Map<String, dynamic>>[].obs;
  final RxInt selectedKuisId = 0.obs;
  final RxBool noQuiz = false.obs;
  final RxBool voiceEnabled = false.obs;
  final VoiceCommandController voiceCommandController =
      Get.find<VoiceCommandController>();
  late final int materiId;
  late final String materiTitle;

  int get kuisId {
    final selected = selectedKuisId.value;
    if (selected > 0) return selected;
    final direct = kuis['id'] ?? kuis['kuis_id'];
    return int.tryParse(direct?.toString() ?? '') ?? 0;
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    materiId = int.tryParse(args['materi_id']?.toString() ?? '') ?? 0;
    materiTitle = args['materi_title']?.toString() ?? 'Materi';
    fetchQuiz();
  }

  @override
  void onReady() {
    super.onReady();
    Future.microtask(enableVoiceOnOpen);
  }

  @override
  void onClose() {
    VoiceGuideService.instance.stop();
    if (voiceEnabled.value) {
      voiceCommandController.stopListening();
      voiceEnabled.value = false;
    }
    super.onClose();
  }

  Future<void> fetchQuiz() async {
    if (materiId == 0) {
      error.value = 'Materi tidak valid.';
      noQuiz.value = true;
      return;
    }
    isLoading.value = true;
    error.value = '';
    noQuiz.value = false;
    try {
      final res = await QuizService.materiQuiz(materiId);
      if (res.containsKey('error')) {
        final fallback = await _fallbackQuizFromList();
        if (fallback.isEmpty) {
          error.value = res['error'].toString();
          noQuiz.value = true;
        } else {
          _applyQuizCollection(fallback);
        }
      } else {
        final extracted = _extractQuizCollection(res);
        if (extracted.isNotEmpty) {
          _applyQuizCollection(extracted);
        } else {
          final fallback = await _fallbackQuizFromList();
          if (fallback.isEmpty) {
            error.value = 'Kuis belum tersedia untuk materi ini.';
            noQuiz.value = true;
          } else {
            _applyQuizCollection(fallback);
          }
        }
      }
      if (error.value.isEmpty) {
        await speakIntroGuide();
      }
    } catch (e) {
      error.value = e.toString();
      noQuiz.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, dynamic>> _extractQuizCollection(Map<String, dynamic> res) {
    final items = <Map<String, dynamic>>[];

    void addItem(dynamic value) {
      if (value is Map) {
        items.add(value.cast<String, dynamic>());
      }
    }

    final list = res['kuis_list'] ?? res['data'];
    if (list is List) {
      for (final item in list) {
        addItem(item);
      }
    }

    addItem(res['kuis']);
    addItem(res['data']);
    if (res['id'] != null) {
      addItem(res);
    }

    final deduped = <int, Map<String, dynamic>>{};
    for (final item in items) {
      final id = int.tryParse(
        (item['id'] ?? item['kuis_id'] ?? item['quiz_id'])?.toString() ?? '',
      );
      if (id != null && id > 0) {
        deduped[id] = item;
      }
    }
    if (deduped.isNotEmpty) return deduped.values.toList();
    return items;
  }

  void _applyQuizCollection(List<Map<String, dynamic>> items) {
    kuisList.assignAll(items);
    error.value = '';
    noQuiz.value = false;

    final defaultId = _defaultQuizIdFromItems(items);
    final selected = defaultId > 0 ? defaultId : _firstQuizId(items);
    selectedKuisId.value = selected;
    final active = _findQuizById(items, selected) ?? items.first;
    kuis.assignAll(active);
  }

  int _defaultQuizIdFromItems(List<Map<String, dynamic>> items) {
    final current = _quizIdOf(kuis);
    if (current > 0 && _findQuizById(items, current) != null) {
      return current;
    }
    for (final item in items) {
      if (!_looksCompleted(item)) return _quizIdOf(item);
    }
    return _firstQuizId(items);
  }

  int _firstQuizId(List<Map<String, dynamic>> items) {
    for (final item in items) {
      final id = _quizIdOf(item);
      if (id > 0) return id;
    }
    return 0;
  }

  Map<String, dynamic>? _findQuizById(List<Map<String, dynamic>> items, int id) {
    for (final item in items) {
      if (_quizIdOf(item) == id) return item;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> _fallbackQuizFromList() async {
    try {
      final res = await QuizService.list();
      if (res.containsKey('error')) return const [];
      final payload = res['data'] is Map
          ? (res['data'] as Map).cast<String, dynamic>()
          : res;

      final materi = payload['kuis_materi'] ?? payload['materi'];
      List<Map<String, dynamic>> items = const [];
      if (materi is List) {
        items = materi.cast<Map<String, dynamic>>();
      } else if (payload['data'] is List) {
        items = (payload['data'] as List)
            .cast<Map<String, dynamic>>()
            .where((item) {
              final nested = item['materi'];
              return item['materi_id'] != null || nested != null;
            })
            .toList();
      }
      if (items.isEmpty) return const [];

      final matches = items.where((item) => _materiIdOf(item) == materiId).toList();
      if (matches.isEmpty) return const [];
      return matches;
    } catch (_) {
      return const [];
    }
  }

  int _quizIdOf(Map<String, dynamic> item) {
    final nested = item['kuis'];
    final raw =
        item['id'] ??
        item['kuis_id'] ??
        item['quiz_id'] ??
        (nested is Map ? nested['id'] ?? nested['kuis_id'] : null);
    return int.tryParse(raw?.toString() ?? '') ?? 0;
  }

  int _materiIdOf(Map<String, dynamic> item) {
    final nested = item['materi'];
    final raw =
        item['materi_id'] ??
        (nested is Map ? nested['id'] ?? nested['materi_id'] : null);
    return int.tryParse(raw?.toString() ?? '') ?? 0;
  }

  bool _looksCompleted(Map<String, dynamic> item) {
    return item['is_completed'] == true ||
        item['completed'] == true ||
        item['sudah_dikerjakan'] == true ||
        item['has_submitted'] == true ||
        item['hasil_id'] != null ||
        item['skor'] != null ||
        item['nilai'] != null ||
        item['score'] != null;
  }

  void selectQuiz(Map<String, dynamic> item) {
    final id = _quizIdOf(item);
    if (id <= 0) return;
    selectedKuisId.value = id;
    kuis.assignAll(item);
  }

  Future<void> enableVoiceOnOpen() async {
    if (voiceEnabled.value) return;
    final res = await Permission.microphone.request();
    if (res.isGranted) {
      voiceEnabled.value = true;
      await voiceCommandController.startListening();
    }
  }

  Future<void> speakIntroGuide() async {
    if (isLoading.value) return;
    final total = kuis['pertanyaan_count']?.toString();
    final title = kuis['judul']?.toString() ?? 'Kuis materi';
    final totalKuis = kuisList.length;
    final detail = total != null && total.isNotEmpty
        ? '$total soal siap dikerjakan.'
        : 'Kuis siap dikerjakan.';
    final extra = totalKuis > 1
        ? ' Ada $totalKuis kuis untuk materi ini. Kuis yang dipilih saat ini $title.'
        : '';
    await VoiceGuideService.instance.speak(
      'Kuis untuk $materiTitle siap.$extra $detail '
      'Ucapkan mulai kuis untuk masuk ke soal pertama, atau kembali untuk ke materi.',
    );
  }

  void startQuiz() {
    if (kuisId == 0 || isLoading.value || error.value.isNotEmpty) return;
    Get.toNamed(
      AppRoutes.profileQuizDetail,
      arguments: {
        'kuis_id': kuisId,
        'materi_id': materiId,
      },
    );
  }
}
