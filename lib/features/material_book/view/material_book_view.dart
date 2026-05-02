import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/widgets/voice_command_button.dart';
import '../../../core/widgets/voice_command_scope.dart';
import '../controller/material_book_controller.dart';

class MaterialBookView extends GetView<MaterialBookController> {
  const MaterialBookView({super.key});

  @override
  Widget build(BuildContext context) {
    return VoiceCommandScope(
      commands: {
        'mulai belajar': controller.openFirstBab,
        'mulai materi': controller.openFirstBab,
        'lanjut belajar': controller.continueReading,
        'lanjut materi': controller.continueReading,
        'buka bab satu': controller.openFirstBab,
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F4ED),
        body: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value && controller.babList.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.orange),
              );
            }

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: const Color(0xFFF8F4ED),
                  surfaceTintColor: Colors.transparent,
                  pinned: true,
                  elevation: 0,
                  title: Text(
                    controller.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textBlack,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  actions: const [
                    Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: VoiceCommandButton(size: 38),
                    ),
                  ],
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _heroCard(),
                      const SizedBox(height: 18),
                      _summaryRow(),
                      const SizedBox(height: 18),
                      _actionRow(),
                      const SizedBox(height: 22),
                      _aboutSection(),
                      const SizedBox(height: 22),
                      _chapterSection(),
                    ]),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _heroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFE0B2), Color(0xFFFFF3E0), Color(0xFFE8F1FF)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 112,
              height: 148,
              color: Colors.white,
              child: controller.coverImage.isNotEmpty
                  ? Image.network(
                      controller.coverImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _coverFallback(),
                    )
                  : _coverFallback(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    controller.category,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.orange,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  controller.title,
                  style: const TextStyle(
                    fontSize: 22,
                    height: 1.2,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textBlack,
                  ),
                ),
                if (controller.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    controller.subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Text(
                  controller.totalBabLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6C5B3C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow() {
    return Row(
      children: [
        Expanded(
          child: _infoCard(
            icon: Icons.view_list_rounded,
            title: 'Daftar isi',
            value: controller.totalBabLabel,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _infoCard(
            icon: Icons.menu_book_rounded,
            title: 'Mulai dari',
            value: controller.babList.isEmpty ? '-' : 'Bab 1',
          ),
        ),
      ],
    );
  }

  Widget _actionRow() {
    final hasBab = controller.babList.isNotEmpty;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: hasBab ? controller.openFirstBab : null,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text(
              'Mulai Pelajari Materi',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: hasBab ? controller.continueReading : null,
            icon: const Icon(Icons.history_rounded),
            label: const Text(
              'Lanjutkan Bacaan Terakhir',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.orange,
              side: const BorderSide(color: AppColors.orange),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _aboutSection() {
    final aboutText = controller.isLoading.value && controller.description.isEmpty
        ? 'Memuat deskripsi materi...'
        : controller.description.isEmpty
        ? 'Deskripsi materi belum tersedia.'
        : controller.description;
    return _sectionShell(
      title: 'Tentang Materi',
      child: Text(
        aboutText,
        style: TextStyle(
          fontSize: 14,
          height: 1.6,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _chapterSection() {
    if (controller.error.value.isNotEmpty && controller.babList.isEmpty) {
      return _sectionShell(
        title: 'Daftar Bab',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.error.value,
              style: const TextStyle(color: Colors.redAccent),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: controller.fetchDetail,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }

    return _sectionShell(
      title: 'Daftar Bab',
      child: controller.babList.isEmpty
          ? const Text('Bab belum tersedia.')
          : Column(
              children: List.generate(controller.babList.length, (index) {
                final bab = controller.babList[index];
                final title =
                    bab['judul_bab']?.toString() ??
                    bab['judul']?.toString() ??
                    'Bab ${index + 1}';
                final hasQuiz =
                    bab['kuis'] != null ||
                    bab['kuis_id'] != null ||
                    bab['quiz_id'] != null ||
                    (bab['kuis_list'] is List &&
                        (bab['kuis_list'] as List).isNotEmpty);
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == controller.babList.length - 1 ? 0 : 12,
                  ),
                  child: InkWell(
                    onTap: () => controller.openBab(index),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8FB),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE6EAF2)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.orange.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: AppColors.orange,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textBlack,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  hasQuiz
                                      ? 'Bab ini punya kuis di akhir bacaan'
                                      : 'Buka untuk mulai membaca bab ini',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: AppColors.orange,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.orange, size: 22),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionShell({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
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
              fontWeight: FontWeight.w900,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _coverFallback() {
    return const Center(
      child: Icon(
        Icons.menu_book_rounded,
        color: AppColors.orange,
        size: 40,
      ),
    );
  }
}
