import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/aac_controller.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/widgets/primary_header.dart';
import '../../../core/widgets/voice_command_scope.dart';
import '../../../core/widgets/voice_command_button.dart';

class AacView extends GetView<AacController> {
  const AacView({super.key});

  // ── Warna konsisten dengan DashboardView ──────────────────────────────────
  static const Color _bgWarm     = Color(0xFFFFF8F3);
  static const Color _borderSoft = Color(0xFFF0E8E0);
  static const Color _textDark   = Color(0xFF1A1A2E);
  static const Color _textGrey   = Color(0xFF888888);

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
        backgroundColor: _bgWarm,
        body: Stack(
          children: [
            // ── Bubble dekoratif (konsisten dengan DashboardView) ───────────
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: AppColors.yellow.withOpacity(0.45),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 80,
              left: -50,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: AppColors.orange.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              right: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.yellow.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // ── Konten utama ─────────────────────────────────────────────
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 12),
                  Expanded(
                    child: RefreshIndicator(
                      color: AppColors.orange,
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
                              return _buildLoadingState(
                                  'Memuat kata & ungkapan AAC...');
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
                              padding:
                                  const EdgeInsets.fromLTRB(20, 6, 20, 24),
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
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.orange,
                                      ),
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
          ],
        ),
      ),
    );
  }

  // ── Header (konsisten dengan DashboardView) ───────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: _bgWarm,
        border: Border(
          bottom: BorderSide(color: _borderSoft, width: 1.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Row(
          children: [
            // Icon + judul
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.yellow,
                borderRadius: BorderRadius.circular(14),
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
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AAC',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.orange,
                    fontFamily: 'Nunito',
                    letterSpacing: 0.5,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Komunikasi Alternatif',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _textGrey,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Voice button (sama gaya DashboardView)
            _VoicePulseButton(
              child: VoiceCommandButton(size: 44),
            ),
          ],
        ),
      ),
    );
  }

  // ── Loading state ─────────────────────────────────────────────────────────
  Widget _buildLoadingState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.orange),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
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

  // ── Empty / error state ───────────────────────────────────────────────────
  Widget _emptyState({
    required String message,
    required VoidCallback onRetry,
  }) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
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
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.yellow.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.record_voice_over_rounded,
                  size: 32,
                  color: AppColors.orange,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                  color: _textGrey,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: onRetry,
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
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
                  child: const Center(
                    child: Text(
                      'Muat Ulang',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── AAC Card (konsisten gaya card DashboardView) ──────────────────────────
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
            // ── Gambar ──────────────────────────────────────────────────
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(18)),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: imageUrl == null || imageUrl.isEmpty
                          ? Container(
                              color: AppColors.yellow.withOpacity(0.25),
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
                                  color: AppColors.yellow.withOpacity(0.25),
                                  child: const Icon(
                                    Icons.broken_image_rounded,
                                    color: AppColors.orange,
                                    size: 36,
                                  ),
                                );
                              },
                            ),
                    ),
                    // ── Speaker badge ──────────────────────────────────
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.88),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.orange.withOpacity(0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
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

            // ── Teks ────────────────────────────────────────────────────
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
                        color: AppColors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: AppColors.orange,
                          fontFamily: 'Nunito',
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
                      fontWeight: FontWeight.w900,
                      color: _textDark,
                      fontFamily: 'Nunito',
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
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w600,
                        color: _textGrey,
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

// ── Voice pulse button (identik dengan DashboardView) ────────────────────────
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