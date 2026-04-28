import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/aac_controller.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/widgets/primary_header.dart';
import '../../../core/widgets/voice_command_scope.dart';
import '../../../core/widgets/voice_command_button.dart';

class AacView extends GetView<AacController> {
  const AacView({super.key});

  @override
  Widget build(BuildContext context) {
    void scrollBy(double delta) {
      final c = controller.scrollController;
      if (!c.hasClients) return;
      final target = (c.offset + delta).clamp(0.0, c.position.maxScrollExtent);
      c.animateTo(
        target,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }

    void scrollToTop() {
      final c = controller.scrollController;
      if (!c.hasClients) return;
      c.animateTo(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    }

    return VoiceCommandScope(
      commands: {
        'muat ulang': controller.refreshAac,
        'refresh': controller.refreshAac,
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
        body: SafeArea(
          child: Column(
            children: [
              const PrimaryHeader(
                title: 'AAC (Komunikasi)',
                trailing: VoiceCommandButton(),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: controller.refreshAac,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification.metrics.pixels >=
                          notification.metrics.maxScrollExtent - 240) {
                        controller.fetchAac();
                      }
                      return false;
                    },
                    child: Obx(
                      () {
                        if (controller.isLoading.value &&
                            controller.items.isEmpty) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (controller.errorMessage.value.isNotEmpty &&
                            controller.items.isEmpty) {
                          return _emptyState(
                            message: controller.errorMessage.value,
                            onRetry: controller.refreshAac,
                          );
                        }

                        if (controller.items.isEmpty) {
                          return _emptyState(
                            message: 'Belum ada kata/ungkapan AAC.',
                            onRetry: controller.refreshAac,
                          );
                        }

                        return GridView.builder(
                          controller: controller.scrollController,
                          padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.86,
                          ),
                          itemCount: controller.items.length +
                              (controller.isLoading.value ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= controller.items.length) {
                              return const Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              );
                            }
                            final item = controller.items[index];
                            return _aacCard(
                              item: item,
                              onTap: () => controller.speakItem(item),
                              imageUrl: controller.resolveImageUrl(
                                item['gambar_url']?.toString(),
                              ),
                            );
                          },
                        );
                      },
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

  Widget _emptyState({
    required String message,
    required VoidCallback onRetry,
  }) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
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
              const Icon(Icons.record_voice_over_rounded,
                  size: 42, color: AppColors.orange),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textBlack,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Muat Ulang'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _aacCard({
    required Map<String, dynamic> item,
    required VoidCallback onTap,
    required String? imageUrl,
  }) {
    final title = item['judul']?.toString() ?? '';
    final category = item['kategori']?.toString() ?? '';
    final description = item['deskripsi']?.toString() ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
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
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(18)),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: imageUrl == null || imageUrl.isEmpty
                          ? Container(
                              color: const Color(0xFFFFF3E0),
                              child: const Icon(
                                Icons.image_rounded,
                                color: AppColors.orange,
                                size: 36,
                              ),
                            )
                          : Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: const Color(0xFFFFF3E0),
                                  child: const Icon(
                                    Icons.broken_image_rounded,
                                    color: AppColors.orange,
                                    size: 36,
                                  ),
                                );
                              },
                            ),
                    ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.volume_up_rounded,
                          color: AppColors.orange,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (category.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.orange.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.orange,
                        ),
                      ),
                    ),
                  if (category.isNotEmpty) const SizedBox(height: 6),
                  Text(
                    title.isEmpty ? 'Tanpa Judul' : title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textBlack,
                    ),
                  ),
                  if (description.isNotEmpty) const SizedBox(height: 4),
                  if (description.isNotEmpty)
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
