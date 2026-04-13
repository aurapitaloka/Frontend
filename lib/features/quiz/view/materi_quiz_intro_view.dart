import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/materi_quiz_intro_controller.dart';
import '../../../core/utils/app_colors.dart';
import '../../../routes/app_routes.dart';

class MateriQuizIntroView extends GetView<MateriQuizIntroController> {
  const MateriQuizIntroView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            children: [
              _celebrateHeader(),
              const SizedBox(height: 20),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.error.value.isNotEmpty) {
                    return _emptyQuizState(controller.error.value);
                  }
                  return _quizCard();
                }),
              ),
              Obx(() {
                final disabled = controller.kuisId == 0 ||
                    controller.isLoading.value ||
                    controller.error.value.isNotEmpty;
                return SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: disabled
                        ? null
                        : () {
                            Get.toNamed(
                              AppRoutes.profileQuizDetail,
                              arguments: {'kuis_id': controller.kuisId},
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Lanjut Uji Kemampuan',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 10),
              TextButton(
                onPressed: Get.back,
                child: const Text('Kembali ke materi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _celebrateHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.emoji_events_rounded, color: AppColors.orange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hebat! Kamu sudah selesai',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textBlack,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  controller.materiTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quizCard() {
    final title = controller.kuis['judul']?.toString() ?? 'Kuis Materi';
    final total = controller.kuis['pertanyaan_count']?.toString();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ayo lanjut uji pemahamanmu!',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.orange,
            ),
          ),
          if (total != null) ...[
            const SizedBox(height: 6),
            Text(
              '$total soal • Siap kapan saja',
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Klik tombol di bawah untuk mulai kuis materi ini.',
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _emptyQuizState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.orange, size: 36),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textBlack,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Kamu tetap hebat. Kuis untuk materi ini belum tersedia.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: controller.fetchQuiz,
              child: const Text('Coba lagi'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.profileQuiz),
              child: const Text('Lihat kuis lain'),
            ),
          ],
        ),
      ),
    );
  }
}
