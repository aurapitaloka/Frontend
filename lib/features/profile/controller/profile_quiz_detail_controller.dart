import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/controllers/voice_command_controller.dart';
import '../../../core/services/quiz_service.dart';
import '../../../core/services/voice_guide_service.dart';

class ProfileQuizDetailController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString error = ''.obs;
  final RxMap<String, dynamic> kuis = <String, dynamic>{}.obs;
  final RxInt currentQuestionIndex = 0.obs;
  final RxBool isCompleted = false.obs;
  final RxString completedScore = ''.obs;
  final RxBool voiceEnabled = false.obs;
  final RxBool isSpeakingQuestion = false.obs;
  final RxBool showVoiceStartPrompt = false.obs;
  final RxString voicePromptText =
      'Ucapkan mulai untuk memulai kuis berbasis suara.'.obs;

  final RxMap<int, int> jawaban = <int, int>{}.obs;
  final RxMap<String, String> selectedOptionKeys = <String, String>{}.obs;
  final RxMap<int, String> jawabanTeks = <int, String>{}.obs;
  final VoiceCommandController voiceCommandController =
      Get.find<VoiceCommandController>();

  late final int kuisId;
  late final int materiId;
  late final bool voiceStart;

  @override
  void onInit() {
    super.onInit();
    kuisId = int.tryParse(Get.arguments?['kuis_id']?.toString() ?? '') ?? 0;
    materiId = int.tryParse(Get.arguments?['materi_id']?.toString() ?? '') ?? 0;
    isCompleted.value = Get.arguments?['is_completed'] == true;
    completedScore.value = Get.arguments?['score']?.toString() ?? '';
    voiceStart = Get.arguments?['voice_start'] == true;
    fetchDetail();
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
      final res = materiId > 0 && kuisId > 0
          ? await QuizService.materiQuizDetail(materiId, kuisId)
          : kuisId > 0
          ? await QuizService.detail(kuisId)
          : await QuizService.materiQuiz(materiId);
      if (res.containsKey('error')) {
        error.value = res['error'].toString();
      } else {
        final detail = _extractQuiz(res);
        if (detail != null) {
          kuis.assignAll(detail);
          currentQuestionIndex.value = 0;
          _showVoicePrompt();
        } else {
          error.value =
              res['message']?.toString() ?? 'Data kuis tidak ditemukan.';
        }
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
      if (voiceStart && error.value.isEmpty && questions.isNotEmpty) {
        await speakStartPrompt();
      }
    }
  }

  void _showVoicePrompt() {
    if (isCompleted.value || questions.isEmpty) return;
    showVoiceStartPrompt.value = true;
    voicePromptText.value =
        'Ucapkan "mulai" untuk mendengar soal pertama.\n'
        'Setelah soal dibacakan, ucapkan "A", "B", "C", atau "D" untuk menjawab.\n'
        'Kalau ingin mendengar lagi, ucapkan "ulangi soal".';
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
      }
    }
    return null;
  }

  void setJawaban(int pertanyaanId, int opsiId) {
    jawaban[pertanyaanId] = opsiId;
  }

  void setSelectedOptionKey(String questionKey, String selectionKey) {
    selectedOptionKeys[questionKey] = selectionKey;
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

  Future<void> enableVoiceOnOpen() async {
    if (voiceEnabled.value) return;
    final res = await Permission.microphone.request();
    if (res.isGranted) {
      voiceEnabled.value = true;
      await voiceCommandController.enableContinuousListening();
    }
  }

  List<Map<String, dynamic>> get questions {
    final raw =
        kuis['pertanyaan'] ??
        kuis['pertanyaans'] ??
        kuis['questions'] ??
        kuis['soal'];
    if (raw is List) {
      return raw.cast<Map<String, dynamic>>();
    }
    return const [];
  }

  Map<String, dynamic>? get currentQuestion {
    final list = questions;
    if (list.isEmpty) return null;
    final index = currentQuestionIndex.value.clamp(0, list.length - 1);
    return list[index];
  }

  Future<void> speakStartPrompt() async {
    if (!voiceStart || isCompleted.value || questions.isEmpty) return;
    showVoiceStartPrompt.value = true;
    await _speakWithVoicePause(
      'Mode kuis suara aktif. Ucapkan mulai untuk memulai soal pertama. '
      'Setelah soal dibacakan, cukup jawab A, B, C, atau D.',
      resumeListening: true,
    );
  }

  Future<void> startVoiceQuizSession() async {
    if (questions.isEmpty) return;
    showVoiceStartPrompt.value = false;
    await speakCurrentQuestion();
  }

  Future<void> speakCurrentQuestion() async {
    final question = currentQuestion;
    if (question == null) return;

    final text =
        (question['pertanyaan'] ??
                question['teks'] ??
                question['question'] ??
                question['soal'])
            ?.toString() ??
        '';
    final rawOptions =
        (question['opsi'] ?? question['opsi_jawaban'] ?? question['options'])
            as List?;
    final options = (rawOptions?.cast<Map<String, dynamic>>() ?? const [])
        .where((option) {
          return _normalizeOptionLabel(option['label']) != null;
        })
        .toList();

    final optionTexts = options
        .map((option) {
          final label = _normalizeOptionLabel(option['label'])?.toUpperCase() ?? '';
          final content =
              (option['teks'] ?? option['text'] ?? option['jawaban'])
                  ?.toString() ??
              '';
          if (label.isEmpty || content.isEmpty) return '';
          return 'Pilihan $label. $content.';
        })
        .where((item) => item.isNotEmpty)
        .join(' ');

    final number = currentQuestionIndex.value + 1;
    final total = questions.length;
    final spoken =
        'Soal $number dari $total. $text. $optionTexts '
        'Silakan jawab dengan ucapkan A, B, C, atau D.';

    await _speakWithVoicePause(spoken, resumeListening: true);
  }

  bool hasAnswer(Map<String, dynamic> question) {
    final id = _questionIdOf(question);
    final stateKey = _questionStateKeyOf(question);
    if (selectedOptionKeys.containsKey(stateKey)) return true;
    if (id == 0) return false;
    final text = jawabanTeks[id]?.trim() ?? '';
    return jawaban.containsKey(id) || text.isNotEmpty;
  }

  Future<void> goToQuestionFromVoice(String spoken) async {
    final list = questions;
    if (list.isEmpty) return;
    final match = RegExp(r'(?:nomor|soal)\s*(\d+)').firstMatch(spoken);
    final number = int.tryParse(match?.group(1) ?? '');
    if (number == null || number <= 0 || number > list.length) {
      await _speakWithVoicePause(
        'Nomor soal tidak ditemukan.',
        resumeListening: true,
      );
      return;
    }
    currentQuestionIndex.value = number - 1;
    showVoiceStartPrompt.value = false;
    await speakCurrentQuestion();
  }

  Future<void> answerCurrentByLabelVoice(String label) async {
    final list = questions;
    if (list.isEmpty) return;

    final index = currentQuestionIndex.value.clamp(0, list.length - 1);
    final question = list[index];
    final questionId = _questionIdOf(question);
    final questionStateKey = _questionStateKeyOf(question, fallbackIndex: index);

    final rawOptions =
        (question['opsi'] ?? question['opsi_jawaban'] ?? question['options'])
            as List?;
    final options = (rawOptions?.cast<Map<String, dynamic>>() ?? const [])
        .where((option) {
          return _normalizeOptionLabel(option['label']) != null;
        })
        .toList();
    final target = _normalizeAnswerLabel(label);
    if (target == null) {
      await _speakWithVoicePause(
        'Jawaban $label belum dikenali.',
        resumeListening: true,
      );
      return;
    }

    Map<String, dynamic>? selected;
    for (final option in options) {
      final optionLabel = _normalizeOptionLabel(option['label']);
      if (optionLabel == target) {
        selected = option;
        break;
      }
    }
    if (selected == null) {
      await _speakWithVoicePause(
        'Pilihan $label tidak tersedia pada soal ini.',
        resumeListening: true,
      );
      return;
    }

    final optionId = _optionIdOf(selected);
    final selectionKey = _optionSelectionKey(selected);
    if (selectionKey.isNotEmpty) {
      setSelectedOptionKey(questionStateKey, selectionKey);
    }
    if (optionId != 0) {
      setJawaban(questionId, optionId);
    }

    final answerText =
        (selected['teks'] ?? selected['text'] ?? selected['jawaban'])
            ?.toString() ??
        '';
    var feedback = 'Jawaban $label dipilih.';
    if (answerText.isNotEmpty) {
      feedback += ' $answerText.';
    }

    final isLast = index >= list.length - 1;
    if (isLast) {
      feedback += ' Semua soal selesai. Jawaban akan dikirim.';
      await _speakWithVoicePause(feedback, resumeListening: false);
      final res = await submit();
      if (res != null) {
        final skor = res['skor']?.toString() ?? '-';
        final benar = res['total_benar']?.toString() ?? '-';
        final total = res['total_pertanyaan']?.toString() ?? '-';
        await _speakWithVoicePause(
          'Kuis selesai. Nilai kamu $skor. Benar $benar dari $total soal.',
          resumeListening: true,
        );
      }
      return;
    }

    feedback += ' Lanjut ke soal berikutnya.';
    await _speakWithVoicePause(feedback, resumeListening: false);
    nextQuestion(list.length);
    await speakCurrentQuestion();
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
      final res = materiId > 0 && kuisId > 0
          ? await QuizService.submitByMateriAndKuisId(materiId, kuisId, payload)
          : kuisId > 0
          ? await QuizService.submitByKuisId(kuisId, payload)
          : await QuizService.submitByMateriId(materiId, payload);
      if (res.containsKey('error')) {
        error.value = res['error'].toString();
        return null;
      }
      isCompleted.value = true;
      completedScore.value = res['skor']?.toString() ?? completedScore.value;
      showVoiceStartPrompt.value = false;
      return res;
    } catch (e) {
      error.value = e.toString();
      return null;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> _speakWithVoicePause(
    String text, {
    required bool resumeListening,
  }) async {
    isSpeakingQuestion.value = true;
    if (voiceEnabled.value) {
      await voiceCommandController.pauseListening();
    }
    await VoiceGuideService.instance.speak(text);
    isSpeakingQuestion.value = false;
    if (resumeListening && voiceEnabled.value && !isCompleted.value) {
      await Future.delayed(const Duration(milliseconds: 450));
      await voiceCommandController.enableContinuousListening();
    }
  }

  String? _normalizeOptionLabel(dynamic value) {
    final text = value?.toString().toLowerCase().trim() ?? '';
    if (text.isEmpty) return null;
    final cleaned = text.replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (cleaned.isEmpty) return null;
    final first = cleaned[0];
    return const {'a', 'b', 'c', 'd'}.contains(first) ? first : null;
  }

  String? _normalizeAnswerLabel(String value) {
    final text = value.toLowerCase().trim();
    const aliases = <String, String>{
      'a': 'a',
      'e': 'a',
      'eh': 'a',
      'ae': 'a',
      'ha': 'a',
      'b': 'b',
      'be': 'b',
      'bee': 'b',
      'bi': 'b',
      'c': 'c',
      'ce': 'c',
      'ci': 'c',
      'si': 'c',
      'd': 'd',
      'de': 'd',
      'di': 'd',
      'the': 'd',
    };
    final cleaned = text.replaceAll(RegExp(r'[^a-z]'), '');
    return aliases[cleaned];
  }

  int _questionIdOf(Map<String, dynamic> question) {
    final candidates = <dynamic>[
      question['id'],
      question['pertanyaan_id'],
      question['question_id'],
      question['soal_id'],
    ];
    for (final candidate in candidates) {
      final parsed = int.tryParse(candidate?.toString() ?? '');
      if (parsed != null && parsed > 0) return parsed;
    }
    return 0;
  }

  int _optionIdOf(Map<String, dynamic> option) {
    final candidates = <dynamic>[
      option['id'],
      option['opsi_id'],
      option['option_id'],
      option['pilihan_id'],
      option['jawaban_id'],
    ];
    for (final candidate in candidates) {
      final parsed = int.tryParse(candidate?.toString() ?? '');
      if (parsed != null && parsed > 0) return parsed;
    }
    return 0;
  }

  String _optionSelectionKey(Map<String, dynamic> option) {
    final optionId = _optionIdOf(option);
    if (optionId > 0) return 'id:$optionId';

    final label = _normalizeOptionLabel(option['label']) ?? '';
    final text =
        (option['teks'] ?? option['text'] ?? option['jawaban'] ?? '')
            .toString()
            .trim()
            .toLowerCase();
    return 'label:$label|text:$text';
  }

  String _questionStateKeyOf(
    Map<String, dynamic> question, {
    int? fallbackIndex,
  }) {
    final questionId = _questionIdOf(question);
    if (questionId > 0) return 'id:$questionId';

    final text =
        (question['pertanyaan'] ??
                question['teks'] ??
                question['question'] ??
                question['soal'] ??
                '')
            .toString()
            .trim()
            .toLowerCase();
    if (text.isNotEmpty) return 'text:$text';
    if (fallbackIndex != null) return 'index:$fallbackIndex';
    return 'question:${question.hashCode}';
  }
}
