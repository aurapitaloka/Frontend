import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/profile_quiz_detail_controller.dart';
import '../../../core/controllers/voice_command_controller.dart';
import '../../../core/services/voice_guide_service.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/widgets/voice_command_button.dart';
import '../../../core/widgets/voice_command_scope.dart';

class ProfileQuizDetailView extends GetView<ProfileQuizDetailController> {
  const ProfileQuizDetailView({super.key});

  static const Color _bgWarm     = Color(0xFFFFF8F3);
  static const Color _borderSoft = Color(0xFFF0E8E0);
  static const Color _textDark   = Color(0xFF1A1A2E);
  static const Color _textGrey   = Color(0xFF888888);
  static const Color _surfaceWhite = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final questions = _questions(controller.kuis);
      return VoiceCommandScope(
        commands: _voiceCommands(questions),
        child: Scaffold(
          backgroundColor: _bgWarm,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return _buildLoadingState();
                    }
                    if (controller.error.value.isNotEmpty) {
                      return _errorState(controller.error.value);
                    }
                    if (controller.isCompleted.value) {
                      return _completedState();
                    }
                    if (questions.isEmpty) {
                      return _errorState('Soal kuis belum tersedia.');
                    }
                    return _quizPager(questions: questions);
                  }),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: _bgWarm,
        border: Border(
          bottom: BorderSide(color: _borderSoft, width: 1.5),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: Get.back,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _surfaceWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _borderSoft, width: 1.5),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.orange,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Icon + Title
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.yellow,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.yellow.withOpacity(0.5),
                  blurRadius: 0,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.quiz_rounded,
              color: AppColors.orange,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detail Kuis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.orange,
                    fontFamily: 'Nunito',
                    height: 1,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Kerjakan dengan teliti',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _textGrey,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),

          // Voice button
          _VoicePulseButton(
            child: VoiceCommandButton(size: 44),
          ),
        ],
      ),
    );
  }

  // ── Loading state (konsisten DashboardView) ───────────────────────────────
  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.orange),
            const SizedBox(height: 16),
            const Text(
              'Memuat soal kuis...',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Voice commands (tidak berubah) ────────────────────────────────────────
  Map<String, VoidCallback> _voiceCommands(
    List<Map<String, dynamic>> questions,
  ) {
    return {
      'mulai': () => controller.startVoiceQuizSession(),
      'mulai kuis': () => controller.startVoiceQuizSession(),
      'mulai soal': () => controller.startVoiceQuizSession(),
      'bacakan soal': () => controller.speakCurrentQuestion(),
      'ulangi soal': () => controller.speakCurrentQuestion(),
      'ulangi': () => controller.speakCurrentQuestion(),
      'selanjutnya': () => _voiceNext(questions),
      'lanjut': () => _voiceNext(questions),
      'berikutnya': () => _voiceNext(questions),
      'sebelumnya': () => _voicePrevious(questions),
      'kembali': () => _voicePrevious(questions),
      'soal nomor': () => _goToQuestionFromVoice(),
      'nomor': () => _goToQuestionFromVoice(),
      'a': () => controller.answerCurrentByLabelVoice('a'),
      'langsung a': () => controller.answerCurrentByLabelVoice('a'),
      'e': () => controller.answerCurrentByLabelVoice('a'),
      'eh': () => controller.answerCurrentByLabelVoice('a'),
      'b': () => controller.answerCurrentByLabelVoice('b'),
      'langsung b': () => controller.answerCurrentByLabelVoice('b'),
      'be': () => controller.answerCurrentByLabelVoice('b'),
      'c': () => controller.answerCurrentByLabelVoice('c'),
      'langsung c': () => controller.answerCurrentByLabelVoice('c'),
      'ce': () => controller.answerCurrentByLabelVoice('c'),
      'd': () => controller.answerCurrentByLabelVoice('d'),
      'langsung d': () => controller.answerCurrentByLabelVoice('d'),
      'de': () => controller.answerCurrentByLabelVoice('d'),
      'jawab a': () => controller.answerCurrentByLabelVoice('a'),
      'jawab e': () => controller.answerCurrentByLabelVoice('a'),
      'jawab b': () => controller.answerCurrentByLabelVoice('b'),
      'jawab c': () => controller.answerCurrentByLabelVoice('c'),
      'jawab d': () => controller.answerCurrentByLabelVoice('d'),
      'jawaban a': () => controller.answerCurrentByLabelVoice('a'),
      'jawaban b': () => controller.answerCurrentByLabelVoice('b'),
      'jawaban c': () => controller.answerCurrentByLabelVoice('c'),
      'jawaban d': () => controller.answerCurrentByLabelVoice('d'),
      'pilih a': () => controller.answerCurrentByLabelVoice('a'),
      'pilihan a': () => controller.answerCurrentByLabelVoice('a'),
      'huruf a': () => controller.answerCurrentByLabelVoice('a'),
      'pilih b': () => controller.answerCurrentByLabelVoice('b'),
      'pilihan b': () => controller.answerCurrentByLabelVoice('b'),
      'huruf b': () => controller.answerCurrentByLabelVoice('b'),
      'pilih c': () => controller.answerCurrentByLabelVoice('c'),
      'pilihan c': () => controller.answerCurrentByLabelVoice('c'),
      'huruf c': () => controller.answerCurrentByLabelVoice('c'),
      'pilih d': () => controller.answerCurrentByLabelVoice('d'),
      'pilihan d': () => controller.answerCurrentByLabelVoice('d'),
      'huruf d': () => controller.answerCurrentByLabelVoice('d'),
      'opsi a': () => controller.answerCurrentByLabelVoice('a'),
      'opsi e': () => controller.answerCurrentByLabelVoice('a'),
      'opsi b': () => controller.answerCurrentByLabelVoice('b'),
      'opsi be': () => controller.answerCurrentByLabelVoice('b'),
      'opsi c': () => controller.answerCurrentByLabelVoice('c'),
      'opsi ce': () => controller.answerCurrentByLabelVoice('c'),
      'opsi d': () => controller.answerCurrentByLabelVoice('d'),
      'opsi de': () => controller.answerCurrentByLabelVoice('d'),
      'kirim jawaban': () => _submitVoice(questions),
      'selesai': () => _submitVoice(questions),
      'stop baca': () => VoiceGuideService.instance.stop(),
    };
  }

  Future<void> _goToQuestionFromVoice() async {
    final voice = Get.find<VoiceCommandController>();
    await controller.goToQuestionFromVoice(voice.lastWords.value);
  }

  void _voiceNext(List<Map<String, dynamic>> questions) {
    if (controller.isSpeakingQuestion.value || controller.isSubmitting.value) {
      return;
    }
    if (questions.isEmpty) return;
    final isLast =
        controller.currentQuestionIndex.value >= questions.length - 1;
    if (isLast) return;
    controller.showVoiceStartPrompt.value = false;
    controller.nextQuestion(questions.length);
    controller.speakCurrentQuestion();
  }

  void _voicePrevious(List<Map<String, dynamic>> questions) {
    if (controller.isSpeakingQuestion.value || controller.isSubmitting.value) {
      return;
    }
    if (questions.isEmpty) return;
    controller.showVoiceStartPrompt.value = false;
    controller.previousQuestion(questions.length);
    controller.speakCurrentQuestion();
  }

  Future<void> _submitVoice(List<Map<String, dynamic>> questions) async {
    if (controller.isSpeakingQuestion.value) return;
    if (questions.isEmpty || controller.isSubmitting.value) return;
    final isLast =
        controller.currentQuestionIndex.value >= questions.length - 1;
    if (!isLast) {
      controller.nextQuestion(questions.length);
      await controller.speakCurrentQuestion();
      return;
    }
    final res = await controller.submit();
    if (res != null) _showResult(res);
  }

  // ── Quiz pager ────────────────────────────────────────────────────────────
  Widget _quizPager({
    required List<Map<String, dynamic>> questions,
  }) {
    return Obx(() {
      final total = questions.length;
      final index = controller.currentQuestionIndex.value.clamp(0, total - 1);
      final question = questions[index];

      return LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 620;
          return Padding(
            padding: EdgeInsets.fromLTRB(16, compact ? 8 : 14, 16, 12),
            child: Column(
              children: [
                _questionMap(questions, index, compact: compact),
                SizedBox(height: compact ? 8 : 10),
                _voiceStatusBadge(compact: compact),
                if (controller.showVoiceStartPrompt.value) ...[
                  SizedBox(height: compact ? 8 : 10),
                  _voiceGuideCard(compact: compact),
                ],
                SizedBox(height: compact ? 8 : 10),
                Expanded(
                  child: _questionCard(
                    question,
                    index + 1,
                    total,
                    compact: compact,
                  ),
                ),
                SizedBox(height: compact ? 8 : 10),
                _navigationBar(
                  isFirst: index == 0,
                  isLast: index == total - 1,
                  totalQuestions: total,
                  compact: compact,
                ),
              ],
            ),
          );
        },
      );
    });
  }

  // ── Voice guide card ──────────────────────────────────────────────────────
  Widget _voiceGuideCard({required bool compact}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 14,
        vertical: compact ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD166), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 34 : 38,
            height: compact ? 34 : 38,
            decoration: BoxDecoration(
              color: AppColors.orange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.record_voice_over_rounded,
              color: AppColors.orange,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Obx(
              () => Text(
                controller.voicePromptText.value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: compact ? 10.5 : 11.5,
                  height: 1.3,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF514000),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          TextButton(
            onPressed: _showVoiceGuideSheet,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Panduan',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                fontFamily: 'Nunito',
              ),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: controller.startVoiceQuizSession,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 10 : 14,
                vertical: compact ? 8 : 10,
              ),
              decoration: BoxDecoration(
                color: AppColors.orange,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.orange.withOpacity(0.35),
                    blurRadius: 0,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                compact ? 'Mulai' : 'Mulai Bacakan',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontFamily: 'Nunito',
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => controller.showVoiceStartPrompt.value = false,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: AppColors.orange,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _voiceStatusBadge({required bool compact}) {
    return Obx(() {
      final isSpeaking = controller.isSpeakingQuestion.value;
      final bg = isSpeaking ? const Color(0xFFFFF3CD) : const Color(0xFFEAF7ED);
      final border =
          isSpeaking ? const Color(0xFFFFD166) : const Color(0xFFBEE3C8);
      final iconColor =
          isSpeaking ? AppColors.orange : const Color(0xFF2F855A);
      final textColor =
          isSpeaking ? const Color(0xFF7A5800) : const Color(0xFF1F5E3D);
      final icon = isSpeaking ? Icons.volume_up_rounded : Icons.mic_rounded;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 12,
          vertical: compact ? 8 : 9,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: 1.3),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: compact ? 15 : 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                controller.voiceInteractionStatus.value,
                style: TextStyle(
                  fontSize: compact ? 11 : 12,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  fontFamily: 'Nunito',
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _showVoiceGuideSheet() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFF8F3),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0E8E0),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.yellow,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.yellow.withOpacity(0.5),
                          blurRadius: 0,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.record_voice_over_rounded,
                      color: AppColors.orange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Panduan Suara Kuis',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: _textDark,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF0E8E0), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => Text(
                        controller.voicePromptText.value,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: _textGrey,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Perintah yang bisa dipakai:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: _textDark,
                        fontFamily: 'Nunito',
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...[
                      ('mulai', 'membacakan soal pertama'),
                      ('a / b / c / d', 'menjawab langsung via suara'),
                      ('ulangi soal', 'membacakan soal lagi'),
                      ('selanjutnya / sebelumnya', 'pindah soal'),
                    ].map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 3),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '"${item.$1}" ',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.orange,
                                        fontFamily: 'Nunito',
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'untuk ${item.$2}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: _textGrey,
                                        fontFamily: 'Nunito',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ── Title card ────────────────────────────────────────────────────────────
  // ── Question map (peta soal) ──────────────────────────────────────────────
  Widget _questionMap(
    List<Map<String, dynamic>> questions,
    int activeIndex, {
    required bool compact,
  }) {
    return Obx(() {
      controller.jawaban.length;
      controller.jawabanTeks.length;
      controller.selectedOptionKeys.length;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(compact ? 12 : 14),
        decoration: BoxDecoration(
          color: _surfaceWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _borderSoft, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.orange.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.yellow.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.event_seat_rounded,
                    color: AppColors.orange,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Peta Soal',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: _textDark,
                    fontFamily: 'Nunito',
                  ),
                ),
                const Spacer(),
                if (!compact)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF7ED),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'aktif menyala',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF3B6D11),
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: compact ? 8 : 10),
            LayoutBuilder(
              builder: (context, constraints) {
                final maxColumns =
                    questions.length <= 10 ? questions.length : 10;
                final columns = maxColumns == 0 ? 1 : maxColumns;
                final available = constraints.maxWidth - ((columns - 1) * 6);
                final seatWidth = (available / columns).clamp(
                  24.0,
                  compact ? 34.0 : 40.0,
                );
                final seatHeight = compact ? 28.0 : 34.0;

                return Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: List.generate(questions.length, (index) {
                    final isActive = index == activeIndex;
                    final isAnswered =
                        controller.hasAnswer(questions[index]);
                    final bgColor = isActive
                        ? AppColors.orange
                        : isAnswered
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFF0E8E0);
                    return GestureDetector(
                      onTap: () => controller.goToQuestion(
                        index,
                        questions.length,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: seatWidth,
                        height: seatHeight,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(9),
                            topRight: Radius.circular(9),
                            bottomLeft: Radius.circular(5),
                            bottomRight: Radius.circular(5),
                          ),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isActive || isAnswered
                                ? Colors.white
                                : _textGrey,
                            fontSize: compact ? 11 : 13,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ],
        ),
      );
    });
  }

  // ── Question card ─────────────────────────────────────────────────────────
  Widget _questionCard(
    Map<String, dynamic> q,
    int number,
    int total, {
    required bool compact,
  }) {
    final id = _questionIdOf(q);
    final questionStateKey =
        _questionStateKeyOf(q, fallbackIndex: number - 1);
    final teks =
        (q['pertanyaan'] ?? q['teks'] ?? q['question'] ?? q['soal'])
            ?.toString() ??
        '-';
    final tipe = q['tipe']?.toString() ?? 'pilihan';
    final opsi = _visibleOptions(
      ((q['opsi'] ?? q['opsi_jawaban'] ?? q['options']) as List?)
              ?.cast<Map<String, dynamic>>() ??
          [],
    );
    final audioText = q['audio_text']?.toString();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 14 : 18),
      decoration: BoxDecoration(
        color: _surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderSoft, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.orange.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Soal header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.yellow.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Soal $number',
                  style: const TextStyle(
                    color: Color(0xFFC14900),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0E8E0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$number/$total',
                  style: const TextStyle(
                    color: _textGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 10 : 14),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    teks,
                    style: TextStyle(
                      fontSize: compact ? 15 : 17,
                      fontWeight: FontWeight.w900,
                      color: _textDark,
                      fontFamily: 'Nunito',
                      height: 1.35,
                    ),
                  ),
                  if (audioText != null && audioText.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3CD),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFFD166),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.volume_up_rounded,
                            color: AppColors.orange,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              audioText,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF514000),
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: compact ? 12 : 16),
                  if (opsi.length > 4) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: AppColors.orange.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.swipe_down_rounded,
                            size: 14,
                            color: AppColors.orange,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Geser ke bawah untuk semua pilihan',
                            style: TextStyle(
                              fontSize: compact ? 10.5 : 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.orange,
                              fontFamily: 'Nunito',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (tipe == 'pilihan' || tipe == 'listening')
                    _optionsGrid(
                      opsi,
                      id,
                      questionStateKey: questionStateKey,
                      compact: compact,
                    )
                  else
                    TextField(
                      minLines: 4,
                      maxLines: compact ? 5 : 7,
                      onChanged: (value) =>
                          controller.setJawabanTeks(id, value),
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: _textDark,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Tulis jawaban...',
                        hintStyle: const TextStyle(
                          color: Color(0xFFCCCCCC),
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w600,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFFFF8F3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFF0E8E0),
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFF0E8E0),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColors.orange,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Options grid ──────────────────────────────────────────────────────────
  Widget _optionsGrid(
    List<Map<String, dynamic>> options,
    int questionId, {
    required String questionStateKey,
    required bool compact,
  }) {
    if (options.isEmpty) {
      return Center(
        child: Text(
          'Pilihan jawaban belum tersedia.',
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w600,
            color: _textGrey,
          ),
        ),
      );
    }
    final gap = compact ? 6.0 : 8.0;
    return Column(
      children: options.map((option) {
        final isLast = option == options.last;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : gap),
          child: _optionTile(
            option,
            questionId,
            questionStateKey: questionStateKey,
            compact: compact,
          ),
        );
      }).toList(),
    );
  }

  List<Map<String, dynamic>> _visibleOptions(
      List<Map<String, dynamic>> options) {
    return options.where((option) {
      return _normalizedOptionLabel(option['label']) != null;
    }).toList();
  }

  // ── Option tile ───────────────────────────────────────────────────────────
  Widget _optionTile(
    Map<String, dynamic> option,
    int questionId, {
    required String questionStateKey,
    required bool compact,
  }) {
    final opsiId = _optionIdOf(option);
    final selectionKey = _optionSelectionKey(option);
    final label =
        _normalizedOptionLabel(option['label'])?.toUpperCase() ??
        option['label']?.toString() ??
        '';
    final text =
        (option['teks'] ?? option['text'] ?? option['jawaban'])?.toString() ??
        '';

    return Obx(() {
      final selected =
          (opsiId > 0 && controller.jawaban[questionId] == opsiId) ||
          controller.selectedOptionKeys[questionStateKey] == selectionKey;

      return GestureDetector(
        onTap: () {
          controller.setSelectedOptionKey(questionStateKey, selectionKey);
          if (opsiId > 0) {
            controller.setJawaban(questionId, opsiId);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 12 : 14,
            vertical: compact ? 10 : 12,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.orange.withOpacity(0.08)
                : const Color(0xFFFFF8F3),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.orange : _borderSoft,
              width: selected ? 2 : 1.5,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.orange.withOpacity(0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              // Label circle
              Container(
                width: compact ? 32 : 36,
                height: compact ? 32 : 36,
                decoration: BoxDecoration(
                  color: selected ? AppColors.orange : AppColors.yellow,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (selected ? AppColors.orange : AppColors.yellow)
                          .withOpacity(0.5),
                      blurRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.orange,
                    fontWeight: FontWeight.w900,
                    fontSize: compact ? 13 : 14,
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  maxLines: compact ? 3 : 4,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    fontSize: compact ? 13 : 14,
                    fontWeight: FontWeight.w700,
                    color: selected ? _textDark : _textGrey,
                    fontFamily: 'Nunito',
                    height: 1.3,
                  ),
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 8),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.orange,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  // ── Navigation bar ────────────────────────────────────────────────────────
  Widget _navigationBar({
    required bool isFirst,
    required bool isLast,
    required int totalQuestions,
    required bool compact,
  }) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: isFirst
                ? null
                : () => controller.previousQuestion(totalQuestions),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: compact ? 46 : 52,
              decoration: BoxDecoration(
                color: isFirst
                    ? const Color(0xFFF0E8E0)
                    : _surfaceWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isFirst ? const Color(0xFFF0E8E0) : _borderSoft,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: isFirst ? const Color(0xFFCCCCCC) : AppColors.orange,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Sebelumnya',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color:
                          isFirst ? const Color(0xFFCCCCCC) : AppColors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Obx(
            () => GestureDetector(
              onTap: controller.isSubmitting.value
                  ? null
                  : () async {
                      controller.showVoiceStartPrompt.value = false;
                      if (!isLast) {
                        controller.nextQuestion(totalQuestions);
                        return;
                      }
                      final res = await controller.submit();
                      if (res != null) _showResult(res);
                    },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: compact ? 46 : 52,
                decoration: BoxDecoration(
                  color: isLast
                      ? const Color(0xFF4CAF50)
                      : AppColors.orange,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: (isLast
                              ? const Color(0xFF4CAF50)
                              : AppColors.orange)
                          .withOpacity(0.35),
                      blurRadius: 0,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: controller.isSubmitting.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLast ? 'Kirim Jawaban' : 'Selanjutnya',
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            isLast
                                ? Icons.send_rounded
                                : Icons.arrow_forward_ios_rounded,
                            size: 15,
                            color: Colors.white,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Completed state ───────────────────────────────────────────────────────
  Widget _completedState() {
    final score = controller.completedScore.value.isNotEmpty
        ? controller.completedScore.value
        : '-';
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFF98A),
                Color(0xFFFFEA3D),
                Color(0xFFFFD92E),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD92E).withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  color: Color(0xFF4CAF50),
                  size: 40,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Kuis Sudah Dikerjakan! 🎉',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFB93D00),
                  fontFamily: 'Nunito',
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'Nilai kamu: $score',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF9B3A00),
                    fontFamily: 'Nunito',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: Get.back,
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.88),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE0B84A).withOpacity(0.4),
                        blurRadius: 0,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Kembali ke Profil',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFC14900),
                      fontFamily: 'Nunito',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helper methods (tidak berubah) ────────────────────────────────────────
  List<Map<String, dynamic>> _questions(Map<String, dynamic> kuis) {
    final raw =
        kuis['pertanyaan'] ??
        kuis['pertanyaans'] ??
        kuis['questions'] ??
        kuis['soal'];
    if (raw is List) return raw.cast<Map<String, dynamic>>();
    return const [];
  }

  Widget _errorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Colors.red,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 14,
                height: 1.5,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: controller.fetchDetail,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.orange.withOpacity(0.35),
                      blurRadius: 0,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Text(
                  'Coba Lagi',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _normalizedOptionLabel(dynamic value) {
    final text = value?.toString().toLowerCase().trim() ?? '';
    if (text.isEmpty) return null;
    final cleaned = text.replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (cleaned.isEmpty) return null;
    final first = cleaned[0];
    return const {'a', 'b', 'c', 'd'}.contains(first) ? first : null;
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
    final opsiId = _optionIdOf(option);
    if (opsiId > 0) return 'id:$opsiId';
    final label = _normalizedOptionLabel(option['label']) ?? '';
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

  void _showResult(Map<String, dynamic> res) {
    final skor = res['skor']?.toString() ?? '-';
    final benar = res['total_benar']?.toString() ?? '-';
    final total = res['total_pertanyaan']?.toString() ?? '-';
    final scoreNumber = double.tryParse(skor) ?? 0;
    final isGreat = scoreNumber >= 80;
    final isOkay = scoreNumber >= 60;
    final badgeColor = isGreat
        ? const Color(0xFF4CAF50)
        : isOkay
        ? AppColors.orange
        : const Color(0xFFFF7043);
    final badgeGradient = isGreat
        ? [const Color(0xFFE8F5E9), const Color(0xFFFFF8F3)]
        : isOkay
        ? [const Color(0xFFFFF98A), const Color(0xFFFFF3CD)]
        : [const Color(0xFFFFEBEE), const Color(0xFFFFF8F3)];

    controller.isCompleted.value = true;
    controller.completedScore.value = skor;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: badgeGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isGreat
                      ? Icons.emoji_events_rounded
                      : isOkay
                      ? Icons.thumb_up_rounded
                      : Icons.sentiment_satisfied_rounded,
                  color: badgeColor,
                  size: 42,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Kuis Selesai!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: _textDark,
                  fontFamily: 'Nunito',
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Nilai yang kamu dapat',
                style: TextStyle(
                  fontSize: 13,
                  color: _textGrey,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: badgeColor.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      skor,
                      style: TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        color: badgeColor,
                        fontFamily: 'Nunito',
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Benar $benar dari $total soal',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Get.back();
                  Get.back();
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.orange,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.orange.withOpacity(0.35),
                        blurRadius: 0,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Selesai',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VoicePulseButton extends StatefulWidget {
  final Widget child;

  const _VoicePulseButton({required this.child});

  @override
  State<_VoicePulseButton> createState() => _VoicePulseButtonState();
}

class _VoicePulseButtonState extends State<_VoicePulseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ScaleTransition(
          scale: _scale,
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.orange.withOpacity(0.25),
                width: 2,
              ),
            ),
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.orange,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.orange.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: widget.child,
        ),
      ],
    );
  }
}
