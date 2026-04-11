import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/profile_quiz_controller.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/widgets/primary_header.dart';
import '../../../routes/app_routes.dart';

class ProfileQuizView extends GetView<ProfileQuizController> {
  const ProfileQuizView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            PrimaryHeader(
              title: 'Kuis',
              trailing: IconButton(
                onPressed: Get.back,
                icon: const Icon(Icons.close_rounded, color: AppColors.orange),
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
                return RefreshIndicator(
                  onRefresh: controller.fetchKuis,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _heroCard(
                        totalUmum: controller.kuisUmum.length,
                        totalMateri: controller.kuisMateri.length,
                        completed: controller.completedMateriIds.length,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _sectionTitle('Kuis Umum'),
                          TextButton(
                            onPressed: () => Get.toNamed(AppRoutes.profileQuizHistory),
                            child: const Text('Riwayat Kuis'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (controller.kuisUmum.isEmpty)
                        _emptyCard('Belum ada kuis umum tersedia.')
                      else
                        ...controller.kuisUmum.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () {
                                Get.toNamed(
                                  AppRoutes.profileQuizDetail,
                                  arguments: {'kuis_id': item['id']},
                                );
                              },
                              child: _quizCard(
                                title: item['judul']?.toString() ?? 'Kuis',
                                subtitle:
                                    '${item['pertanyaan_count'] ?? 0} soal',
                                status: (item['status_aktif'] == true)
                                    ? 'Aktif'
                                    : 'Nonaktif',
                                color: const Color(0xFF4CAF50),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      _sectionTitle('Kuis Materi'),
                      const SizedBox(height: 10),
                      if (controller.kuisMateri.isEmpty)
                        _emptyCard('Belum ada kuis materi tersedia.')
                      else
                        ...controller.kuisMateri.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () {
                                Get.toNamed(
                                  AppRoutes.profileQuizDetail,
                                  arguments: {'kuis_id': item['id']},
                                );
                              },
                              child: _quizMateriCard(item),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroCard({
    required int totalUmum,
    required int totalMateri,
    required int completed,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
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
            child: const Icon(Icons.quiz_rounded, color: AppColors.orange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Latih pemahamanmu',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textBlack,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$totalUmum kuis umum • $totalMateri kuis materi • $completed materi selesai',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textBlack,
                    height: 1.4,
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quizCard({
    required String title,
    required String subtitle,
    required String status,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.task_alt_rounded, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textBlack,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quizMateriCard(Map<String, dynamic> item) {
    final materi = item['materi'] as Map<String, dynamic>? ?? {};
    final materiId = materi['id']?.toString();
    final progress = materiId != null ? controller.progressMap[materiId] : null;
    final progressValue = (progress is Map && progress['progres'] != null)
        ? progress['progres'].toString()
        : '0';
    final status = (item['status_aktif'] == true) ? 'Aktif' : 'Nonaktif';
    return _quizCard(
      title: item['judul']?.toString() ?? 'Kuis Materi',
      subtitle: '${materi['judul'] ?? 'Materi'} • $progressValue% progres',
      status: status,
      color: const Color(0xFF3F51B5),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textBlack,
        fontFamily: 'Roboto',
      ),
    );
  }

  Widget _emptyCard(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey[700],
          fontSize: 13,
          height: 1.4,
        ),
      ),
    );
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
              onPressed: controller.fetchKuis,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
