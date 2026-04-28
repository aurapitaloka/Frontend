import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/profile_quiz_detail_controller.dart';
import '../../../core/controllers/voice_command_controller.dart';
import '../../../core/services/voice_guide_service.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/widgets/primary_header.dart';
import '../../../core/widgets/voice_command_button.dart';
import '../../../core/widgets/voice_command_scope.dart';

class ProfileQuizDetailView extends GetView<ProfileQuizDetailController> {
  const ProfileQuizDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final questions = _questions(controller.kuis);
      return VoiceCommandScope(
        commands: _voiceCommands(questions),
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          body: SafeArea(
            child: Column(
              children: [
                PrimaryHeader(
                  title: 'Detail Kuis',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const VoiceCommandButton(size: 36),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: Get.back,
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppColors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
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
                    return _quizPager(
                      title: controller.kuis['judul']?.toString() ?? 'Kuis',
                      questions: questions,
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

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
      'b': () => controller.answerCurrentByLabelVoice('b'),
      'c': () => controller.answerCurrentByLabelVoice('c'),
      'd': () => controller.answerCurrentByLabelVoice('d'),
      'jawab a': () => controller.answerCurrentByLabelVoice('a'),
      'jawab b': () => controller.answerCurrentByLabelVoice('b'),
      'jawab c': () => controller.answerCurrentByLabelVoice('c'),
      'jawab d': () => controller.answerCurrentByLabelVoice('d'),
      'jawaban a': () => controller.answerCurrentByLabelVoice('a'),
      'jawaban b': () => controller.answerCurrentByLabelVoice('b'),
      'jawaban c': () => controller.answerCurrentByLabelVoice('c'),
      'jawaban d': () => controller.answerCurrentByLabelVoice('d'),
      'pilih a': () => controller.answerCurrentByLabelVoice('a'),
      'pilih b': () => controller.answerCurrentByLabelVoice('b'),
      'pilih c': () => controller.answerCurrentByLabelVoice('c'),
      'pilih d': () => controller.answerCurrentByLabelVoice('d'),
      'opsi a': () => controller.answerCurrentByLabelVoice('a'),
      'opsi b': () => controller.answerCurrentByLabelVoice('b'),
      'opsi c': () => controller.answerCurrentByLabelVoice('c'),
      'opsi d': () => controller.answerCurrentByLabelVoice('d'),
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
    if (questions.isEmpty) return;
    final isLast =
        controller.currentQuestionIndex.value >= questions.length - 1;
    if (isLast) return;
    controller.showVoiceStartPrompt.value = false;
    controller.nextQuestion(questions.length);
    controller.speakCurrentQuestion();
  }

  void _voicePrevious(List<Map<String, dynamic>> questions) {
    if (questions.isEmpty) return;
    controller.showVoiceStartPrompt.value = false;
    controller.previousQuestion(questions.length);
    controller.speakCurrentQuestion();
  }

  Future<void> _submitVoice(List<Map<String, dynamic>> questions) async {
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

  Widget _quizPager({
    required String title,
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
                _titleCard(title, index + 1, total, compact: compact),
                SizedBox(height: compact ? 8 : 10),
                _questionMap(questions, index, compact: compact),
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

  Widget _voiceGuideCard({required bool compact}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD79A)),
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 32 : 34,
            height: compact ? 32 : 34,
            decoration: BoxDecoration(
              color: AppColors.orange.withOpacity(0.14),
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
                  height: 1.25,
                  color: Colors.grey[800],
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
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 4),
          ElevatedButton(
            onPressed: controller.startVoiceQuizSession,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orange,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 10 : 12,
                vertical: compact ? 9 : 10,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              compact ? 'Mulai' : 'Mulai Bacakan',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
            ),
          ),
          IconButton(
            onPressed: () => controller.showVoiceStartPrompt.value = false,
            icon: const Icon(
              Icons.close_rounded,
              color: AppColors.orange,
              size: 18,
            ),
            splashRadius: 18,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  void _showVoiceGuideSheet() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
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
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Panduan Suara Kuis',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Text(
                  controller.voicePromptText.value,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Perintah yang bisa dipakai:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 6),
              const Text('mulai untuk membacakan soal pertama'),
              const Text('a, b, c, atau d untuk menjawab'),
              const Text('ulangi soal untuk membacakan soal lagi'),
              const Text('selanjutnya atau sebelumnya untuk pindah soal'),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _titleCard(
    String title,
    int current,
    int total, {
    required bool compact,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 8 : 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF8E1), Color(0xFFE3F2FD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 34 : 42,
            height: compact ? 34 : 42,
            decoration: BoxDecoration(
              color: AppColors.orange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.quiz_rounded, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: compact ? 13 : 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textBlack,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Soal $current dari $total',
                  style: TextStyle(
                    fontSize: compact ? 10 : 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _questionMap(
    List<Map<String, dynamic>> questions,
    int activeIndex, {
    required bool compact,
  }) {
    return Obx(() {
      controller.jawaban.length;
      controller.jawabanTeks.length;

      return LayoutBuilder(
        builder: (context, constraints) {
          final maxColumns = questions.length <= 10 ? questions.length : 10;
          final columns = maxColumns == 0 ? 1 : maxColumns;
          final available = constraints.maxWidth - ((columns - 1) * 6);
          final seatWidth = (available / columns).clamp(
            24.0,
            compact ? 34.0 : 40.0,
          );
          final seatHeight = compact ? 28.0 : 34.0;

          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(compact ? 8 : 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.event_seat_rounded,
                      color: AppColors.orange,
                    ),
                    const SizedBox(width: 7),
                    const Expanded(
                      child: Text(
                        'Peta soal',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ),
                    if (!compact)
                      Text(
                        'aktif menyala',
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                  ],
                ),
                SizedBox(height: compact ? 6 : 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: List.generate(questions.length, (index) {
                    final isActive = index == activeIndex;
                    final isAnswered = controller.hasAnswer(questions[index]);
                    final color = isActive
                        ? AppColors.orange
                        : isAnswered
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFE0E0E0);
                    return GestureDetector(
                      onTap: () =>
                          controller.goToQuestion(index, questions.length),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: seatWidth,
                        height: seatHeight,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: color,
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
                                : AppColors.textBlack,
                            fontSize: compact ? 11 : 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _questionCard(
    Map<String, dynamic> q,
    int number,
    int total, {
    required bool compact,
  }) {
    final id = int.tryParse(q['id']?.toString() ?? '') ?? 0;
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
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.orange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Soal $number',
                  style: const TextStyle(
                    color: AppColors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '$number/$total',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 8 : 12),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    teks,
                    style: TextStyle(
                      fontSize: compact ? 15 : 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textBlack,
                      height: 1.32,
                    ),
                  ),
                  if (audioText != null && audioText.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8FA),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Audio: $audioText',
                        style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                  SizedBox(height: compact ? 10 : 14),
                  if (opsi.length > 4) ...[
                    Text(
                      'Geser ke bawah untuk melihat semua pilihan jawaban.',
                      style: TextStyle(
                        fontSize: compact ? 10.5 : 11.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (tipe == 'pilihan' || tipe == 'listening')
                    _optionsGrid(opsi, id, compact: compact)
                  else
                    TextField(
                      minLines: 4,
                      maxLines: compact ? 5 : 7,
                      onChanged: (value) => controller.setJawabanTeks(id, value),
                      decoration: InputDecoration(
                        hintText: 'Tulis jawaban...',
                        filled: true,
                        fillColor: const Color(0xFFF7F8FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
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

  Widget _optionsGrid(
    List<Map<String, dynamic>> options,
    int questionId, {
    required bool compact,
  }) {
    if (options.isEmpty) {
      return const Center(child: Text('Pilihan jawaban belum tersedia.'));
    }
    final gap = compact ? 6.0 : 8.0;
    return Column(
      children: options.map((option) {
        final isLast = option == options.last;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : gap),
          child: _optionTile(option, questionId, compact: compact),
        );
      }).toList(),
    );
  }

  List<Map<String, dynamic>> _visibleOptions(List<Map<String, dynamic>> options) {
    const allowedLabels = {'a', 'b', 'c', 'd'};
    return options.where((option) {
      final label = option['label']?.toString().toLowerCase().trim() ?? '';
      return allowedLabels.contains(label);
    }).toList();
  }

  Widget _optionTile(
    Map<String, dynamic> option,
    int questionId, {
    required bool compact,
  }) {
    final opsiId = int.tryParse(option['id']?.toString() ?? '') ?? 0;
    final label = option['label']?.toString() ?? '';
    final text =
        (option['teks'] ?? option['text'] ?? option['jawaban'])?.toString() ??
        '';

    return Obx(() {
      final selected = controller.jawaban[questionId] == opsiId;
      return InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => controller.setJawaban(questionId, opsiId),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 12,
            vertical: compact ? 8 : 10,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.orange.withOpacity(0.12)
                : const Color(0xFFF7F8FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.orange : const Color(0xFFE5E7EB),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: compact ? 14 : 16,
                backgroundColor: selected ? AppColors.orange : Colors.white,
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.orange,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  maxLines: compact ? 3 : 4,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    fontSize: compact ? 13 : 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textBlack,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _navigationBar({
    required bool isFirst,
    required bool isLast,
    required int totalQuestions,
    required bool compact,
  }) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isFirst
                ? null
                : () => controller.previousQuestion(totalQuestions),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: compact ? 11 : 14),
              foregroundColor: AppColors.orange,
              side: const BorderSide(color: AppColors.orange),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Sebelumnya'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Obx(
            () => ElevatedButton(
              onPressed: controller.isSubmitting.value
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
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: compact ? 11 : 14),
                backgroundColor: isLast
                    ? const Color(0xFF4CAF50)
                    : AppColors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: controller.isSubmitting.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(isLast ? 'Kirim Jawaban' : 'Selanjutnya'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _completedState() {
    final score = controller.completedScore.value.isNotEmpty
        ? controller.completedScore.value
        : '-';
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF3E0), Color(0xFFE8F5E9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.verified_rounded,
                color: Color(0xFF4CAF50),
                size: 52,
              ),
              const SizedBox(height: 12),
              const Text(
                'Kuis sudah dikerjakan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Nilai kamu: $score',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.orange,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: Get.back,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Kembali'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: controller.fetchDetail,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }

  void _showResult(Map<String, dynamic> res) {
    final skor = res['skor']?.toString() ?? '-';
    final benar = res['total_benar']?.toString() ?? '-';
    final total = res['total_pertanyaan']?.toString() ?? '-';
    final scoreNumber = double.tryParse(skor) ?? 0;
    final badgeColor = scoreNumber >= 80
        ? const Color(0xFF4CAF50)
        : scoreNumber >= 60
        ? const Color(0xFFFFB300)
        : const Color(0xFFFF7043);

    controller.isCompleted.value = true;
    controller.completedScore.value = skor;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF3E0), Color(0xFFE1F5FE), Color(0xFFE8F5E9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: badgeColor.withOpacity(0.32),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.white,
                  size: 42,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Kuis selesai!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textBlack,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Nilai yang kamu dapat',
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text(
                      skor,
                      style: TextStyle(
                        fontSize: 46,
                        fontWeight: FontWeight.w900,
                        color: badgeColor,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Benar $benar dari $total soal',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textBlack,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Selesai'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
