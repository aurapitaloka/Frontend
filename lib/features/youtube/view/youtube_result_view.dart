import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/utils/app_colors.dart';
import '../../dashboard/controller/dashboard_controller.dart';
import '../../../core/widgets/voice_command_scope.dart';
import '../../../core/widgets/voice_command_button.dart';

class YoutubeResultView extends GetView<DashboardController> {
  const YoutubeResultView({super.key});

  @override
  Widget build(BuildContext context) {
    void scrollBy(double delta) {
      final c = controller.youtubeScrollController;
      if (!c.hasClients) return;
      final target = (c.offset + delta).clamp(0.0, c.position.maxScrollExtent);
      c.animateTo(
        target,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }

    void scrollToTop() {
      final c = controller.youtubeScrollController;
      if (!c.hasClients) return;
      c.animateTo(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    }

    return VoiceCommandScope(
      commands: {
        'scroll': () => scrollBy(320),
        'scroll bawah': () => scrollBy(320),
        'scroll turun': () => scrollBy(320),
        'turun': () => scrollBy(320),
        'lanjut': () => scrollBy(320),
        'ke bawah': () => scrollBy(320),
        'scroll atas': () => scrollBy(-320),
        'naik': () => scrollBy(-320),
        'kembali ke atas': scrollToTop,
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          foregroundColor: AppColors.orange,
          title: Obx(() => Text(
                controller.youtubeSearchQuery.value.isNotEmpty
                    ? 'Hasil: ${controller.youtubeSearchQuery.value}'
                    : 'Hasil Pencarian',
                style: const TextStyle(fontWeight: FontWeight.w700),
              )),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 12),
              child: VoiceCommandButton(size: 36),
            ),
          ],
        ),
        body: Obx(() {
          if (controller.isLoadingYoutube.value) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.orange),
                  SizedBox(height: 12),
                  Text(
                    'AI sedang mencarikan video...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          if (controller.youtubeErrorMessage.value.isNotEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppColors.orange, size: 42),
                    const SizedBox(height: 12),
                    Text(
                      controller.youtubeErrorMessage.value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        final query = controller.youtubeSearchQuery.value;
                        if (query.trim().isEmpty) return;
                        controller.searchYoutubeVideos(query);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (controller.youtubeVideos.isEmpty) {
            return Center(
              child: Text(
                controller.youtubeSearchQuery.value.isNotEmpty
                    ? 'Video untuk "${controller.youtubeSearchQuery.value}" tidak ditemukan.'
                    : 'Video tidak ditemukan.',
              ),
            );
          }

          return ListView(
            controller: controller.youtubeScrollController,
            padding: const EdgeInsets.all(16),
            children: controller.youtubeVideos.map(_buildYoutubeItem).toList(),
          );
        }),
      ),
    );
  }

  Widget _buildYoutubeItem(Map<String, dynamic> video) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _openYoutubeVideo(video['videoId']?.toString()),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Image.network(
                video['thumbnailUrl'] ?? '',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  alignment: Alignment.center,
                  child:
                      const Icon(Icons.smart_display_rounded, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video['title'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.smart_display_rounded,
                          color: AppColors.orange, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          video['channelTitle'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openYoutubeVideo(String? videoId) async {
    if (videoId == null || videoId.isEmpty) return;
    final url = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!ok) {
      Get.snackbar(
        'Gagal membuka video',
        'Tidak bisa membuka YouTube di perangkat ini.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
