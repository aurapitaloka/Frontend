import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/profile_quiz_history_detail_controller.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/date_time_formatter.dart';
import '../../../core/widgets/primary_header.dart';

class ProfileQuizHistoryDetailView extends GetView<ProfileQuizHistoryDetailController> {
  const ProfileQuizHistoryDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            PrimaryHeader(
              title: 'Detail Riwayat',
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
                final hasil = controller.hasil;
                final kuis = hasil['kuis'] as Map<String, dynamic>? ?? {};
                final jawaban =
                    (hasil['jawaban'] as List?)?.cast<Map<String, dynamic>>() ?? [];
                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _summaryCard(
                      title: kuis['judul']?.toString() ?? 'Kuis',
                      skor: hasil['skor']?.toString() ?? '-',
                      totalBenar: hasil['total_benar']?.toString() ?? '-',
                      totalPertanyaan: hasil['total_pertanyaan']?.toString() ?? '-',
                      selesaiAt: DateTimeFormatter.short(hasil['selesai_at']?.toString()),
                    ),
                    const SizedBox(height: 16),
                    ...jawaban.map((j) => _answerCard(j)).toList(),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard({
    required String title,
    required String skor,
    required String totalBenar,
    required String totalPertanyaan,
    required String selesaiAt,
  }) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 8),
          Text('Skor: $skor'),
          Text('Benar: $totalBenar/$totalPertanyaan'),
          Text('Selesai: $selesaiAt'),
        ],
      ),
    );
  }

  Widget _answerCard(Map<String, dynamic> item) {
    final benar = item['benar'] == true;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          Icon(
            benar ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: benar ? const Color(0xFF4CAF50) : Colors.redAccent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pertanyaan #${item['pertanyaan_id']}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textBlack,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Opsi ID: ${item['opsi_id'] ?? '-'}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
                Text(
                  'Status koreksi: ${item['status_koreksi'] ?? '-'}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
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
              onPressed: controller.fetchDetail,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
