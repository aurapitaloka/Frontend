import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/profile_quiz_history_controller.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/date_time_formatter.dart';
import '../../../core/widgets/primary_header.dart';
import '../../../routes/app_routes.dart';

class ProfileQuizHistoryView extends GetView<ProfileQuizHistoryController> {
  const ProfileQuizHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F3),
      body: SafeArea(
        child: Column(
          children: [
            PrimaryHeader(
              title: 'Riwayat Kuis',
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
                if (controller.items.isEmpty) {
                  return _emptyState();
                }
                return RefreshIndicator(
                  onRefresh: controller.fetchHistory,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                    itemCount: controller.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = controller.items[index];
                      final title = item['kuis_judul']?.toString() ?? 'Kuis';
                      final skor = item['skor']?.toString() ?? '-';
                      final benar = item['total_benar']?.toString() ?? '-';
                      final total = item['total_pertanyaan']?.toString() ?? '-';
                      final selesaiAt = DateTimeFormatter.short(item['selesai_at']?.toString());
                      return GestureDetector(
                        onTap: () {
                          Get.toNamed(
                            AppRoutes.profileQuizHistoryDetail,
                            arguments: {'hasil_id': item['hasil_id']},
                          );
                        },
                        child: Container(
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
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.orange.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.history_rounded,
                                  color: AppColors.orange,
                                  size: 22,
                                ),
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
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Skor $skor • Benar $benar/$total',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      selesaiAt,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Text('Belum ada riwayat kuis.'),
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
              onPressed: controller.fetchHistory,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
