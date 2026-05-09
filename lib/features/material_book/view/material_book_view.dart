import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/widgets/voice_command_button.dart';
import '../../../core/widgets/voice_command_scope.dart';
import '../controller/material_book_controller.dart';

class MaterialBookView extends GetView<MaterialBookController> {
  const MaterialBookView({super.key});

  // ── Warna konsisten dengan DashboardView ──────────────────────────────────
  static const Color _bgWarm     = Color(0xFFFFF8F3);
  static const Color _borderSoft = Color(0xFFF0E8E0);
  static const Color _textDark   = Color(0xFF1A1A2E);
  static const Color _textGrey   = Color(0xFF888888);

  @override
  Widget build(BuildContext context) {
    return VoiceCommandScope(
      commands: {
        'mulai belajar':  controller.openFirstBab,
        'mulai materi':   controller.openFirstBab,
        'lanjut belajar': controller.continueReading,
        'lanjut materi':  controller.continueReading,
        'buka bab satu':  controller.openFirstBab,
      },
      child: Scaffold(
        backgroundColor: _bgWarm,
        body: Stack(
          children: [
            // ── Bubble dekoratif ──────────────────────────────────────────
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

            // ── Konten utama ──────────────────────────────────────────────
            SafeArea(
              child: Obx(() {
                if (controller.isLoading.value && controller.babList.isEmpty) {
                  return Column(
                    children: [
                      _buildHeader(),
                      Expanded(child: _buildLoadingState('Memuat materi...')),
                    ],
                  );
                }
                return Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeroCard(),
                            const SizedBox(height: 20),
                            _buildSummaryRow(),
                            const SizedBox(height: 20),
                            _buildActionRow(),
                            const SizedBox(height: 28),
                            _buildSectionLabel('Tentang Materi'),
                            const SizedBox(height: 12),
                            _buildAboutCard(),
                            const SizedBox(height: 28),
                            _buildSectionLabel('Daftar Bab 📖'),
                            const SizedBox(height: 12),
                            _buildChapterList(),
                          ],
                        ),
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

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: _bgWarm,
        border: Border(bottom: BorderSide(color: _borderSoft, width: 1.5)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        children: [
          // Tombol kembali
          GestureDetector(
            onTap: Get.back,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _borderSoft, width: 1.5),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.orange,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Judul
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.orange,
                    fontFamily: 'Nunito',
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  controller.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _textGrey,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),

          // Voice button (pulse, sama dengan Dashboard)
          _VoicePulseButton(
            child: VoiceCommandButton(size: 44),
          ),
        ],
      ),
    );
  }

  // ── Hero card ─────────────────────────────────────────────────────────────
  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF98A), Color(0xFFFFEA3D), Color(0xFFFFD92E)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD92E).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 100,
              height: 136,
              color: Colors.white.withOpacity(0.55),
              child: controller.coverImage.isNotEmpty
                  ? Image.network(
                      controller.coverImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildCoverFallback(),
                    )
                  : _buildCoverFallback(),
            ),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge kategori
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.4), width: 1),
                  ),
                  child: Text(
                    controller.category,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFC14900),
                      fontFamily: 'Nunito',
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  controller.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFB93D00),
                    fontFamily: 'Nunito',
                    height: 1.2,
                  ),
                ),

                if (controller.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.school_rounded,
                          size: 14, color: Color(0xFF755300)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          controller.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF514000),
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 12),
                Text(
                  controller.totalBabLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF9B3A00),
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Summary row ───────────────────────────────────────────────────────────
  Widget _buildSummaryRow() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            icon: Icons.view_list_rounded,
            title: 'Daftar Isi',
            value: controller.totalBabLabel,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            icon: Icons.menu_book_rounded,
            title: 'Mulai Dari',
            value: controller.babList.isEmpty ? '-' : 'Bab 1',
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.yellow.withOpacity(0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.orange, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _textGrey,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: _textDark,
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }

  // ── Action row ────────────────────────────────────────────────────────────
  Widget _buildActionRow() {
    final hasBab = controller.babList.isNotEmpty;
    return Column(
      children: [
        // Tombol utama
        GestureDetector(
          onTap: hasBab ? controller.openFirstBab : null,
          child: Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              color: hasBab ? AppColors.orange : AppColors.orange.withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
              boxShadow: hasBab
                  ? [
                      BoxShadow(
                        color: AppColors.orange.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
                SizedBox(width: 8),
                Text(
                  'Mulai Pelajari Materi',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: Colors.white,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Tombol sekunder
        GestureDetector(
          onTap: hasBab ? controller.continueReading : null,
          child: Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasBab ? AppColors.orange : _borderSoft,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history_rounded,
                  color: hasBab ? AppColors.orange : _textGrey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Lanjutkan Bacaan Terakhir',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: hasBab ? AppColors.orange : _textGrey,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Section label ─────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w900,
        color: _textDark,
        fontFamily: 'Nunito',
        height: 1.2,
      ),
    );
  }

  // ── About card ────────────────────────────────────────────────────────────
  Widget _buildAboutCard() {
    final aboutText = controller.isLoading.value && controller.description.isEmpty
        ? 'Memuat deskripsi materi...'
        : controller.description.isEmpty
            ? 'Deskripsi materi belum tersedia.'
            : controller.description;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Text(
        aboutText,
        style: const TextStyle(
          fontSize: 14,
          height: 1.7,
          color: _textGrey,
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ── Chapter list ──────────────────────────────────────────────────────────
  Widget _buildChapterList() {
    if (controller.error.value.isNotEmpty && controller.babList.isEmpty) {
      return _buildErrorState(controller.error.value);
    }

    if (controller.babList.isEmpty) {
      return _buildEmptyState('Bab belum tersedia.', Icons.menu_book_rounded);
    }

    return Column(
      children: List.generate(controller.babList.length, (i) {
        final bab = controller.babList[i];
        final title =
            bab['judul_bab']?.toString() ??
            bab['judul']?.toString() ??
            'Bab ${i + 1}';
        final hasQuiz =
            bab['kuis'] != null ||
            bab['kuis_id'] != null ||
            bab['quiz_id'] != null ||
            (bab['kuis_list'] is List &&
                (bab['kuis_list'] as List).isNotEmpty);

        return Padding(
          padding: EdgeInsets.only(
              bottom: i == controller.babList.length - 1 ? 0 : 12),
          child: GestureDetector(
            onTap: () => controller.openBab(i),
            child: Container(
              padding: const EdgeInsets.all(16),
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
              child: Row(
                children: [
                  // Nomor bab
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.yellow.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: AppColors.orange,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Teks
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: _textDark,
                            fontFamily: 'Nunito',
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              hasQuiz
                                  ? Icons.task_alt_rounded
                                  : Icons.auto_stories_rounded,
                              size: 13,
                              color: hasQuiz ? AppColors.orange : _textGrey,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              hasQuiz
                                  ? 'Ada kuis di akhir bab'
                                  : 'Buka untuk mulai membaca',
                              style: const TextStyle(
                                fontSize: 12,
                                color: _textGrey,
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        if (hasQuiz) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Kuis tersedia',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: AppColors.orange,
                                fontFamily: 'Nunito',
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Arrow
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.yellow,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.yellow.withOpacity(0.6),
                          blurRadius: 0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.orange,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // ── State helpers ─────────────────────────────────────────────────────────
  Widget _buildLoadingState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
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

  Widget _buildEmptyState(String message, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.yellow.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.orange, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border:
                Border.all(color: Colors.red.withOpacity(0.2), width: 1.5),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: Colors.red, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.red,
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: controller.fetchDetail,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.orange,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.orange.withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Text(
              'Coba lagi',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCoverFallback() {
    return Center(
      child: Icon(
        Icons.menu_book_rounded,
        color: AppColors.orange.withOpacity(0.6),
        size: 40,
      ),
    );
  }
}

// ── Voice pulse button (identik dengan DashboardView) ─────────────────────────
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