import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/rak_buku_controller.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/widgets/voice_command_scope.dart';
import '../../../core/widgets/voice_command_button.dart';
import '../../../core/controllers/voice_command_controller.dart';
import '../../../routes/app_routes.dart';

class RakBukuView extends GetView<RakBukuController> {
  const RakBukuView({super.key});

  // ── Warna konsisten dengan LoginView & DashboardView ─────────────────────
  static const Color _bgWarm     = Color(0xFFFFF8F3);
  static const Color _borderSoft = Color(0xFFF0E8E0);
  static const Color _textDark   = Color(0xFF1A1A2E);
  static const Color _textGrey   = Color(0xFF888888);

  @override
  Widget build(BuildContext context) {
    void scrollBy(double delta) {
      final c = controller.scrollController;
      if (!c.hasClients) return;
      final target =
          (c.offset + delta).clamp(0.0, c.position.maxScrollExtent);
      c.animateTo(target,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }

    void scrollToTop() {
      final c = controller.scrollController;
      if (!c.hasClients) return;
      c.animateTo(0,
          duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
    }

    return VoiceCommandScope(
      commands: {
        'muat ulang': controller.fetchItems,
        'refresh': controller.fetchItems,
        'buka materi': () {
          final voice = Get.find<VoiceCommandController>();
          controller.openMateriFromVoice(voice.lastWords.value);
        },
        'buka materi ini': () {
          final voice = Get.find<VoiceCommandController>();
          controller.openMateriFromVoice(voice.lastWords.value);
        },
        'baca materi': () {
          final voice = Get.find<VoiceCommandController>();
          controller.openMateriFromVoice(voice.lastWords.value);
        },
        'scroll':          () => scrollBy(320),
        'scroll bawah':    () => scrollBy(320),
        'scroll turun':    () => scrollBy(320),
        'turun':           () => scrollBy(320),
        'lanjut':          () => scrollBy(320),
        'ke bawah':        () => scrollBy(320),
        'scroll atas':     () => scrollBy(-320),
        'naik':            () => scrollBy(-320),
        'kembali ke atas': scrollToTop,
      },
      child: Scaffold(
        backgroundColor: _bgWarm,
        body: Stack(
          children: [
            // ── Bubble dekoratif — identik posisi & ukuran dengan Dashboard ─
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
              bottom: 120,
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
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return _buildLoadingState();
                        }
                        if (controller.error.value.isNotEmpty) {
                          return _buildErrorState(controller.error.value);
                        }
                        if (controller.items.isEmpty) {
                          return _buildEmptyState();
                        }
                        return GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          controller: controller.scrollController,
                          itemCount: controller.items.length,
                          padding: const EdgeInsets.only(top: 8, bottom: 100),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 0.58,
                          ),
                          itemBuilder: (context, index) {
                            final entry = controller.items[index];
                            final materi = controller.materiFromEntry(entry);
                            final title =
                                materi['judul']?.toString() ?? 'Materi';
                            final subtitle =
                                '${materi['level']?['nama'] ?? ''}';
                            final cover =
                                materi['cover_url']?.toString() ?? '';
                            final pdfUrl = materi['file_url']?.toString();

                            return GestureDetector(
                              onTap: () {
                                Get.toNamed(
                                  AppRoutes.material,
                                  arguments: {
                                    'title': title,
                                    'subtitle': subtitle,
                                    'category': 'Rak Buku',
                                    'body': materi['konten_teks']
                                            ?.toString() ??
                                        '',
                                    'coverImage': cover,
                                    'pdfUrl': pdfUrl,
                                    'materi_id': materi['id'],
                                  },
                                );
                              },
                              child: _buildBookCard(
                                title: title,
                                subtitle: subtitle,
                                cover: cover,
                              ),
                            );
                          },
                        );
                      }),
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

  // ── Header — SafeArea + struktur identik dengan DashboardView ─────────────
  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: _bgWarm,
        border: Border(
          bottom: BorderSide(color: _borderSoft, width: 1.5),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo + judul halaman — mengikuti pola "brand + subtitle" Dashboard
              Row(
                children: [
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
                      Icons.library_books_rounded,
                      color: AppColors.orange,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rak Buku',
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
                        'Koleksi materi kamu 📚',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _textGrey,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Voice button — identik dengan LoginView & DashboardView
              _VoicePulseButton(
                child: const VoiceCommandButton(size: 44),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Book card ─────────────────────────────────────────────────────────────
  Widget _buildBookCard({
    required String title,
    required String subtitle,
    required String cover,
  }) {
    return Container(
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Cover ──────────────────────────────────────────────────────
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
              child: Container(
                width: double.infinity,
                color: AppColors.yellow.withOpacity(0.25),
                child: cover.isNotEmpty
                    ? Image.network(
                        cover,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _coverPlaceholder(),
                      )
                    : _coverPlaceholder(),
              ),
            ),
          ),

          // ── Info ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.3,
                    fontWeight: FontWeight.w900,
                    color: _textDark,
                    fontFamily: 'Nunito',
                  ),
                ),
                const SizedBox(height: 5),
                if (subtitle.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.orange,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                // Tombol Baca — gaya identik dengan _LoginButton
                Container(
                  width: double.infinity,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.yellow,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE0B84A).withOpacity(0.8),
                        blurRadius: 0,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.menu_book_rounded,
                          color: AppColors.orange, size: 15),
                      SizedBox(width: 5),
                      Text(
                        'Baca',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1A1A2E),
                          fontFamily: 'Nunito',
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _coverPlaceholder() {
    return Center(
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.yellow.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.menu_book_rounded,
          color: AppColors.orange,
          size: 28,
        ),
      ),
    );
  }

  // ── State helpers — styling identik dengan DashboardView ─────────────────
  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.orange),
            const SizedBox(height: 16),
            const Text(
              'Memuat rak buku...',
              style: TextStyle(
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

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded,
                  color: Colors.red, size: 32),
            ),
            const SizedBox(height: 16),
            // Error banner — identik dengan DashboardView._buildErrorState
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: Colors.red.withOpacity(0.2), width: 1.5),
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
            const SizedBox(height: 20),
            // Tombol retry — gaya identik dengan _LoginButton
            GestureDetector(
              onTap: controller.fetchItems,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.yellow,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE0B84A).withOpacity(0.8),
                      blurRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded,
                        color: AppColors.orange, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Coba Lagi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1A1A2E),
                        fontFamily: 'Nunito',
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon container — identik dengan Dashboard empty state
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.yellow.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.library_books_rounded,
                color: AppColors.orange,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Rak Buku Kosong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: _textDark,
                fontFamily: 'Nunito',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tambahkan materi dari beranda\nuntuk disimpan di sini',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _textGrey,
                fontFamily: 'Nunito',
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Voice pulse button — identik persis dengan LoginView & DashboardView ──────
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