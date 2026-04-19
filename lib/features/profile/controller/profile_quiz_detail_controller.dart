import 'package:get/get.dart';
import '../../../core/services/quiz_service.dart';

class ProfileQuizDetailController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString error = ''.obs;
  final RxMap<String, dynamic> kuis = <String, dynamic>{}.obs;
  final RxInt currentQuestionIndex = 0.obs;
  final RxBool isCompleted = false.obs;
  final RxString completedScore = ''.obs;

  final RxMap<int, int> jawaban = <int, int>{}.obs;
  final RxMap<int, String> jawabanTeks = <int, String>{}.obs;

  late final int kuisId;
  late final int materiId;

  @override
  void onInit() {
    super.onInit();
    kuisId = int.tryParse(Get.arguments?['kuis_id']?.toString() ?? '') ?? 0;
    materiId = int.tryParse(Get.arguments?['materi_id']?.toString() ?? '') ?? 0;
    isCompleted.value = Get.arguments?['is_completed'] == true;
    completedScore.value = Get.arguments?['score']?.toString() ?? '';
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    if (isCompleted.value) {
      return;
    }
    if (kuisId == 0 && materiId == 0) {
      error.value = 'ID kuis tidak valid.';
      return;
    }

    isLoading.value = true;
    error.value = '';
    try {
      final res = materiId > 0
          ? await QuizService.materiQuiz(materiId)
          : await QuizService.detail(kuisId);
      if (res.containsKey('error')) {
        error.value = res['error'].toString();
      } else {
        final detail = _extractQuiz(res);
        if (detail != null) {
          kuis.assignAll(detail);
          currentQuestionIndex.value = 0;
        } else {
          error.value =
              res['message']?.toString() ?? 'Data kuis tidak ditemukan.';
        }
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic>? _extractQuiz(Map<String, dynamic> res) {
    final candidates = [res['kuis'], res['quiz'], res['data'], res];
    for (final candidate in candidates) {
      if (candidate is Map) {
        final map = candidate.cast<String, dynamic>();
        if (map['id'] != null || map['pertanyaan'] is List) {
          return map;
        }
        final nested = map['kuis'] ?? map['quiz'];
        if (nested is Map) {
          return nested.cast<String, dynamic>();
        }
        final data = map['data'];
        if (data is Map) {
          return data.cast<String, dynamic>();
        }
      } else {
        continue;
      }
    }
    return null;
  }

  void setJawaban(int pertanyaanId, int opsiId) {
    jawaban[pertanyaanId] = opsiId;
  }

  void setJawabanTeks(int pertanyaanId, String text) {
    jawabanTeks[pertanyaanId] = text;
  }

  void goToQuestion(int index, int totalQuestions) {
    if (totalQuestions <= 0) return;
    currentQuestionIndex.value = index.clamp(0, totalQuestions - 1);
  }

  void nextQuestion(int totalQuestions) {
    goToQuestion(currentQuestionIndex.value + 1, totalQuestions);
  }

  void previousQuestion(int totalQuestions) {
    goToQuestion(currentQuestionIndex.value - 1, totalQuestions);
  }

  bool hasAnswer(Map<String, dynamic> question) {
    final id = int.tryParse(question['id']?.toString() ?? '') ?? 0;
    if (id == 0) return false;
    final text = jawabanTeks[id]?.trim() ?? '';
    return jawaban.containsKey(id) || text.isNotEmpty;
  }

  void answerCurrentByLabel(
    String label,
    List<Map<String, dynamic>> questions,
  ) {
    if (questions.isEmpty) return;
    final index = currentQuestionIndex.value.clamp(0, questions.length - 1);
    final question = questions[index];
    final questionId = int.tryParse(question['id']?.toString() ?? '') ?? 0;
    if (questionId == 0) return;
    final rawOptions =
        (question['opsi'] ?? question['opsi_jawaban'] ?? question['options'])
            as List?;
    final options = rawOptions?.cast<Map<String, dynamic>>() ?? [];
    final target = label.toLowerCase().trim();
    for (final option in options) {
      final optionId = int.tryParse(option['id']?.toString() ?? '') ?? 0;
      final optionLabel = option['label']?.toString().toLowerCase().trim();
      if (optionId > 0 && optionLabel == target) {
        setJawaban(questionId, optionId);
        return;
      }
    }
  }

  Future<Map<String, dynamic>?> submit() async {
    if (isCompleted.value) {
      error.value = 'Kuis ini sudah dikerjakan.';
      return null;
    }
    isSubmitting.value = true;
    try {
      final payload = {
        'jawaban': jawaban.map((k, v) => MapEntry(k.toString(), v)),
        'jawaban_teks': jawabanTeks.map((k, v) => MapEntry(k.toString(), v)),
      };
      final res = materiId > 0
          ? await QuizService.submitByMateriId(materiId, payload)
          : await QuizService.submitByKuisId(kuisId, payload);
      if (res.containsKey('error')) {
        error.value = res['error'].toString();
        return null;
      }
      return res;
    } catch (e) {
      error.value = e.toString();
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }
}
