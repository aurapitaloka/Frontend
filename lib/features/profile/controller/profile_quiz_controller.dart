import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/controllers/voice_command_controller.dart';
import '../../../core/services/quiz_service.dart';
import '../../../core/services/voice_guide_service.dart';
import '../../../routes/app_routes.dart';

class ProfileQuizController extends GetxController {
  static const String _voiceNoSpeechPrompt =
      'Saya belum mendengar suara. Coba ulangi nama kuis atau nomor urut kuis.';
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxList<Map<String, dynamic>> kuisUmum = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> kuisMateri = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> riwayatKuis = <Map<String, dynamic>>[].obs;
  final RxMap<String, dynamic> progressMap = <String, dynamic>{}.obs;
  final RxList<int> completedMateriIds = <int>[].obs;
  final RxBool voiceEnabled = false.obs;
  final VoiceCommandController voiceCommandController =
      Get.find<VoiceCommandController>();

  @override
  void onInit() {
    super.onInit();
    voiceCommandController.pushNoSpeechPrompt(_voiceNoSpeechPrompt);
    fetchKuis();
  }

  @override
  void onReady() {
    super.onReady();
    Future.microtask(enableVoiceOnOpen);
  }

  @override
  void onClose() {
    VoiceGuideService.instance.stop();
    voiceCommandController.popNoSpeechPrompt(_voiceNoSpeechPrompt);
    voiceEnabled.value = false;
    super.onClose();
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

  Future<void> enableVoiceOnOpen() async {
    if (!voiceEnabled.value) {
      final res = await Permission.microphone.request();
      if (!res.isGranted) return;
      voiceEnabled.value = true;
    }
    if (kuisUmum.isNotEmpty || kuisMateri.isNotEmpty) {
      await VoiceGuideService.instance.speak(
        'Menu kuis terbuka. Ucapkan nama kuisnya langsung, '
        'atau ucapkan soal latihan 1 untuk memilih kuis pertama.',
      );
    }
    await voiceCommandController.ensureContinuousListening();
  }

  Future<void> openQuizFromVoice(String spoken) async {
    final target = _findQuizFromVoice(spoken);
    if (target == null) {
      await VoiceGuideService.instance.speak(
        'Kuis yang diminta belum saya temukan. Coba ucapkan judul kuis atau nomor urutnya.',
      );
      return;
    }

    final item = target['item'] as Map<String, dynamic>;
    final isMateri = target['isMateri'] == true;
    final args = <String, dynamic>{
      'kuis_id': quizIdOf(item),
      'is_completed': isCompletedItem(item),
      'score': scoreTextOf(item),
      'voice_start': true,
    };
    if (isMateri) {
      args['materi_id'] = materiIdOf(item);
    }

    await VoiceGuideService.instance.stop();
    await Get.toNamed(AppRoutes.profileQuizDetail, arguments: args);
    await fetchKuis();
  }

  Map<String, dynamic>? _findQuizFromVoice(String spoken) {
    final normalized = normalize(spoken);
    if (normalized.isEmpty) return null;

    final numbered = RegExp(r'(?:nomor|ke|latihan)\s*(\d+)').firstMatch(
      normalized,
    );
    if (numbered != null) {
      final index = int.tryParse(numbered.group(1) ?? '');
      if (index != null && index > 0) {
        final all = [
          ...kuisUmum.map((item) => {'item': item, 'isMateri': false}),
          ...kuisMateri.map((item) => {'item': item, 'isMateri': true}),
        ];
        if (index <= all.length) return all[index - 1];
      }
    }

    for (final item in kuisUmum) {
      final title = normalize(quizTitleOf(item, fallback: ''));
      if (title.isNotEmpty &&
          (normalized.contains(title) || title.contains(normalized))) {
        return {'item': item, 'isMateri': false};
      }
    }
    for (final item in kuisMateri) {
      final title = normalize(quizTitleOf(item, fallback: ''));
      if (title.isNotEmpty &&
          (normalized.contains(title) || title.contains(normalized))) {
        return {'item': item, 'isMateri': true};
      }
    }
    return null;
  }

  int quizIdOf(Map<String, dynamic> item) {
    final nested = item['kuis'];
    final raw =
        item['id'] ??
        item['kuis_id'] ??
        item['quiz_id'] ??
        (nested is Map ? nested['id'] ?? nested['kuis_id'] : null);
    return int.tryParse(raw?.toString() ?? '') ?? 0;
  }

  int materiIdOf(Map<String, dynamic> item) {
    final nested = item['materi'];
    final raw =
        item['materi_id'] ??
        (nested is Map ? nested['id'] ?? nested['materi_id'] : null);
    return int.tryParse(raw?.toString() ?? '') ?? 0;
  }

  String quizTitleOf(Map<String, dynamic> item, {required String fallback}) {
    final nested = item['kuis'];
    final raw =
        item['judul'] ??
        item['title'] ??
        item['kuis_judul'] ??
        (nested is Map ? nested['judul'] ?? nested['title'] : null);
    final title = raw?.toString() ?? '';
    return title.isNotEmpty ? title : fallback;
  }

  bool isCompletedItem(Map<String, dynamic> item) {
    if (_historyForQuiz(item) != null) return true;
    final score = _scoreValue(item);
    return item['is_completed'] == true ||
        item['completed'] == true ||
        item['sudah_dikerjakan'] == true ||
        item['has_submitted'] == true ||
        item['hasil_id'] != null ||
        score != null;
  }

  String statusTextOf(Map<String, dynamic> item) {
    if (isCompletedItem(item)) return 'Selesai';
    return (item['status_aktif'] == false) ? 'Nonaktif' : 'Mulai';
  }

  String scoreTextOf(Map<String, dynamic> item) {
    final history = _historyForQuiz(item);
    if (history != null) return _historyScoreText(history);
    final score = _scoreValue(item);
    return score == null ? '-' : score.toStringAsFixed(score % 1 == 0 ? 0 : 1);
  }

  double? _scoreValue(Map<String, dynamic> item) {
    final raw =
        item['skor'] ??
        item['nilai'] ??
        item['score'] ??
        item['best_score'] ??
        item['skor_terbaik'] ??
        item['nilai_terbaik'];
    return double.tryParse(raw?.toString() ?? '');
  }

  Map<String, dynamic>? _historyForQuiz(Map<String, dynamic> item) {
    final quizId = quizIdOf(item);
    final title = normalize(quizTitleOf(item, fallback: ''));
    for (final history in riwayatKuis) {
      final historyQuizId = _historyQuizId(history);
      final historyTitle = normalize(_historyTitle(history));
      if (quizId > 0 && historyQuizId == quizId) return history;
      if (title.isNotEmpty && title == historyTitle) return history;
    }
    return null;
  }

  int _historyQuizId(Map<String, dynamic> item) {
    final nested = item['kuis'];
    final raw =
        item['kuis_id'] ??
        item['quiz_id'] ??
        item['id_kuis'] ??
        (nested is Map ? nested['id'] ?? nested['kuis_id'] : null);
    return int.tryParse(raw?.toString() ?? '') ?? 0;
  }

  String _historyTitle(Map<String, dynamic> item) {
    final nested = item['kuis'];
    final raw =
        item['kuis_judul'] ??
        item['judul'] ??
        item['title'] ??
        (nested is Map ? nested['judul'] ?? nested['title'] : null);
    final title = raw?.toString() ?? '';
    return title.isNotEmpty ? title : 'Kuis';
  }

  double? _historyScore(Map<String, dynamic> item) {
    final raw =
        item['skor'] ??
        item['nilai'] ??
        item['score'] ??
        item['best_score'] ??
        item['skor_terbaik'] ??
        item['nilai_terbaik'];
    return double.tryParse(raw?.toString() ?? '');
  }

  String _historyScoreText(Map<String, dynamic> item) {
    final score = _historyScore(item);
    return score == null ? '-' : score.toStringAsFixed(score % 1 == 0 ? 0 : 1);
  }

  String normalize(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }
}
