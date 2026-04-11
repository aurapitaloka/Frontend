import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/profile_quiz_detail_controller.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/widgets/primary_header.dart';

class ProfileQuizDetailView extends GetView<ProfileQuizDetailController> {
  const ProfileQuizDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            PrimaryHeader(
              title: 'Detail Kuis',
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
                final pertanyaan =
                    (controller.kuis['pertanyaan'] as List?)?.cast<Map<String, dynamic>>() ?? [];
                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _titleCard(controller.kuis['judul']?.toString() ?? 'Kuis'),
                    const SizedBox(height: 16),
                    ...pertanyaan.map((q) => _questionCard(q)).toList(),
                    const SizedBox(height: 16),
                    Obx(
                      () => ElevatedButton(
                        onPressed: controller.isSubmitting.value
                            ? null
                            : () async {
                                final res = await controller.submit();
                                if (res != null) {
                                  _showResult(res);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: AppColors.orange,
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
                            : const Text('Kirim Jawaban'),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _titleCard(String title) {
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
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textBlack,
        ),
      ),
    );
  }

  Widget _questionCard(Map<String, dynamic> q) {
    final id = int.tryParse(q['id'].toString()) ?? 0;
    final teks = q['pertanyaan']?.toString() ?? '-';
    final tipe = q['tipe']?.toString() ?? 'pilihan';
    final opsi = (q['opsi'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final audioText = q['audio_text']?.toString();
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            teks,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 6),
          if (audioText != null && audioText.isNotEmpty)
            Text(
              'Audio: $audioText',
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          const SizedBox(height: 8),
          if (tipe == 'pilihan' || tipe == 'listening')
            ...opsi.map((o) {
              final opsiId = int.tryParse(o['id'].toString()) ?? 0;
              final label = o['label']?.toString() ?? '';
              final text = o['teks']?.toString() ?? '';
              return Obx(
                () => RadioListTile<int>(
                  dense: true,
                  value: opsiId,
                  groupValue: controller.jawaban[id],
                  onChanged: (value) {
                    if (value != null) controller.setJawaban(id, value);
                  },
                  title: Text('$label. $text'),
                ),
              );
            })
          else
            TextField(
              minLines: 2,
              maxLines: 5,
              onChanged: (value) => controller.setJawabanTeks(id, value),
              decoration: InputDecoration(
                hintText: 'Tulis jawaban...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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

  void _showResult(Map<String, dynamic> res) {
    final skor = res['skor']?.toString() ?? '-';
    final benar = res['total_benar']?.toString() ?? '-';
    final total = res['total_pertanyaan']?.toString() ?? '-';
    Get.dialog(
      AlertDialog(
        title: const Text('Kuis selesai'),
        content: Text('Skor: $skor\nBenar: $benar/$total'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
