import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/profile_quiz_controller.dart';
import '../../../core/controllers/voice_command_controller.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/widgets/primary_header.dart';
import '../../../core/widgets/voice_command_button.dart';
import '../../../core/widgets/voice_command_scope.dart';
import '../../../routes/app_routes.dart';

class ProfileQuizView extends GetView<ProfileQuizController> {
  const ProfileQuizView({super.key});

  static const Color _bgWarm     = Color(0xFFFFF8F3);
  static const Color _borderSoft = Color(0xFFF0E8E0);
  static const Color _textDark   = Color(0xFF1A1A2E);
  static const Color _textGrey   = Color(0xFF888888);

  @override
  Widget build(BuildContext context) {
    return VoiceCommandScope(
      commands: {
        'kuis':               () => _openFromVoice(),
        'buka kuis':          () => _openFromVoice(),
        'soal':               () => _openFromVoice(),
        'buka soal latihan':  () => _openFromVoice(),
        'soal latihan':       () => _openFromVoice(),
        'kuis nomor':         () => _openFromVoice(),
        'riwayat kuis':       () => Get.toNamed(AppRoutes.profileQuizHistory),
        'buka riwayat kuis':  () => Get.toNamed(AppRoutes.profileQuizHistory),
        'muat ulang':         () => controller.fetchKuis(),
        'refresh':            () => controller.fetchKuis(),
        'ulangi panduan':     () => controller.enableVoiceOnOpen(),
      },
      child: Scaffold(
        backgroundColor: _bgWarm,
        body: Stack(
          children: [
            // ── Bubble dekoratif (sama dengan DashboardView) ─────────────
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
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return _buildLoadingState('Memuat kuis...');
                      }
                      if (controller.error.value.isNotEmpty) {
                        return _buildErrorState(controller.error.value);
                      }
                      return RefreshIndicator(
                        color: AppColors.orange,
                        onRefresh: controller.fetchKuis,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                          children: [
                            _buildPodiumCard(),
                            const SizedBox(height: 24),
                            _buildSectionHeader(
                              title: 'Kuis Umum',
                              trailing: GestureDetector(
                                onTap: () => Get.toNamed(AppRoutes.profileQuizHistory),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    'Riwayat',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.orange,
                                      fontFamily: 'Nunito',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (controller.kuisUmum.isEmpty)
                              _buildEmptyState(
                                  'Belum ada kuis umum tersedia.',
                                  Icons.task_alt_rounded)
                            else
                              ...controller.kuisUmum.map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: GestureDetector(
                                    onTap: () => _openQuiz(item),
                                    child: _buildQuizCard(
                                      title: controller.quizTitleOf(
                                          item, fallback: 'Kuis'),
                                      subtitle:
                                          '${item['pertanyaan_count'] ?? 0} soal  •  Nilai ${controller.scoreTextOf(item)}',
                                      status: controller.statusTextOf(item),
                                      accentColor: const Color(0xFF4CAF50),
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 20),
                            _buildSectionHeader(title: 'Kuis Materi'),
                            const SizedBox(height: 12),
                            if (controller.kuisMateri.isEmpty)
                              _buildEmptyState(
                                  'Belum ada kuis materi tersedia.',
                                  Icons.menu_book_rounded)
                            else
                              ...controller.kuisMateri.map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: GestureDetector(
                                    onTap: () =>
                                        _openQuiz(item, isMateri: true),
                                    child: _buildQuizMateriCard(item),
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
          ],
        ),
      ),
    );
  }

  // ── Header (gaya DashboardView) ───────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: _bgWarm,
        border: Border(
          bottom: BorderSide(color: _borderSoft, width: 1.5),
        ),
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kuis',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.orange,
                    fontFamily: 'Nunito',
                    height: 1,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Uji kemampuanmu!',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _textGrey,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),

          // Voice button (gaya DashboardView)
          _VoicePulseButton(
            child: VoiceCommandButton(size: 44),
          ),
        ],
      ),
    );
  }

  // ── Section header ────────────────────────────────────────────────────────
  Widget _buildSectionHeader({required String title, Widget? trailing}) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: _textDark,
            fontFamily: 'Nunito',
            height: 1.2,
          ),
        ),
        const Spacer(),
        if (trailing != null) trailing,
      ],
    );
  }

  // ── Podium card ───────────────────────────────────────────────────────────
  Widget _buildPodiumCard() {
    final top = _topHistory();
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Badge ─────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.4), width: 1),
                ),
                child: const Text(
                  '🏆 Podium Terbaik',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7B5A00),
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.38),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  size: 18,
                  color: Color(0xFFC14900),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          if (top.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.55),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'Belum ada riwayat kuis.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF7B5A00),
                  fontFamily: 'Nunito',
                ),
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _buildPodiumResult(
                    item: top.length > 1 ? top[1] : null,
                    height: 104,
                    color: const Color(0xFF81D4FA),
                    rank: '2',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPodiumResult(
                    item: top.first,
                    height: 136,
                    color: AppColors.orange,
                    rank: '1',
                    isWinner: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPodiumResult(
                    item: top.length > 2 ? top[2] : null,
                    height: 92,
                    color: const Color(0xFFA5D6A7),
                    rank: '3',
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPodiumResult({
    required Map<String, dynamic>? item,
    required double height,
    required Color color,
    required String rank,
    bool isWinner = false,
  }) {
    final title = item == null ? '-' : _historyTitle(item);
    final score = item == null ? '-' : _historyScoreText(item);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isWinner)
          const Icon(Icons.emoji_events_rounded,
              color: Color(0xFFFFB300), size: 28),
        Text(
          score,
          style: TextStyle(
            fontSize: isWinner ? 24 : 17,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF1A1A2E),
            fontFamily: 'Nunito',
          ),
        ),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          height: height,
          padding: EdgeInsets.fromLTRB(8, isWinner ? 10 : 8, 8, 8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                rank,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontFamily: 'Nunito',
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    title,
                    maxLines: isWinner ? 4 : 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isWinner ? 11 : 10,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.96),
                      fontFamily: 'Nunito',
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

  // ── Quiz card (gaya subject item DashboardView) ───────────────────────────
  Widget _buildQuizCard({
    required String title,
    required String subtitle,
    required String status,
    required Color accentColor,
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
      child: Row(
        children: [
          // Icon
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.task_alt_rounded, color: accentColor, size: 28),
          ),
          const SizedBox(width: 14),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: _textDark,
                    fontFamily: 'Nunito',
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: _textGrey,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: accentColor,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Arrow (sama persis DashboardView)
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
    );
  }

  Widget _buildQuizMateriCard(Map<String, dynamic> item) {
    final materi = item['materi'] as Map<String, dynamic>? ?? {};
    return _buildQuizCard(
      title: controller.quizTitleOf(item, fallback: 'Kuis Materi'),
      subtitle:
          '${materi['judul'] ?? 'Materi'}  •  Nilai ${controller.scoreTextOf(item)}',
      status: controller.statusTextOf(item),
      accentColor: AppColors.orange,
    );
  }

  // ── State helpers (sama gaya DashboardView) ───────────────────────────────
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 16),
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: controller.fetchKuis,
              child: const Text(
                'Coba lagi',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers (tidak diubah) ────────────────────────────────────────────────
  Future<void> _openFromVoice() async {
    final voice = Get.find<VoiceCommandController>();
    await controller.openQuizFromVoice(voice.lastWords.value);
  }

  Future<void> _openQuiz(
    Map<String, dynamic> item, {
    bool isMateri = false,
  }) async {
    final args = <String, dynamic>{
      'kuis_id': controller.quizIdOf(item),
      'is_completed': controller.isCompletedItem(item),
      'score': controller.scoreTextOf(item),
    };
    if (isMateri) {
      args['materi_id'] = controller.materiIdOf(item);
    }
    await Get.toNamed(AppRoutes.profileQuizDetail, arguments: args);
    await controller.fetchKuis();
  }

  List<Map<String, dynamic>> _topHistory() {
    final items = [...controller.riwayatKuis];
    items.sort(
      (a, b) => (_historyScore(b) ?? -1).compareTo(_historyScore(a) ?? -1),
    );
    return items.take(3).toList();
  }

  String _historyTitle(Map<String, dynamic> item) {
    final nested = item['kuis'];
    final raw =
        item['kuis_judul'] ??
        item['judul'] ??
        item['title'] ??
        (nested is Map ? nested['judul'] ?? nested['title'] : null);
    final title = raw?.toString() ?? '';
    return title.isNotEmpty ? title : 'Kuis';
  }

  double? _historyScore(Map<String, dynamic> item) {
    final raw =
        item['skor'] ??
        item['nilai'] ??
        item['score'] ??
        item['best_score'] ??
        item['skor_terbaik'] ??
        item['nilai_terbaik'];
    return double.tryParse(raw?.toString() ?? '');
  }

  String _historyScoreText(Map<String, dynamic> item) {
    final score = _historyScore(item);
    return score == null ? '-' : score.toStringAsFixed(score % 1 == 0 ? 0 : 1);
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