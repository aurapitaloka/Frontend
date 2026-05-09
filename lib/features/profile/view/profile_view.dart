import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/profile_controller.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/widgets/primary_header.dart';
import '../../../core/widgets/voice_command_scope.dart';
import '../../../core/widgets/voice_command_button.dart';
import '../../../routes/app_routes.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  // ── Token warna konsisten dengan DashboardView ────────────────────────────
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
        'pengaturan profile': controller.navigateToProfileSettings,
        'pengaturan profil': controller.navigateToProfileSettings,
        'setelan profil': controller.navigateToProfileSettings,
        'edit profil': controller.navigateToProfileSettings,
        'ubah profil': controller.navigateToProfileSettings,
        'buka pengaturan': controller.navigateToProfileSettings,
        'tentang kami': controller.navigateToAboutUs,
        'tentang aplikasi': controller.navigateToAboutUs,
        'info aplikasi': controller.navigateToAboutUs,
        'kuis': () => Get.toNamed(AppRoutes.profileQuiz),
        'buka kuis': () => Get.toNamed(AppRoutes.profileQuiz),
        'catatan': () => Get.toNamed(AppRoutes.profileNotes),
        'buka catatan': () => Get.toNamed(AppRoutes.profileNotes),
        'pengaturan suara': () => Get.toNamed(AppRoutes.profileVoiceSettings),
        'setelan suara': () => Get.toNamed(AppRoutes.profileVoiceSettings),
        'buka pengaturan suara': () =>
            Get.toNamed(AppRoutes.profileVoiceSettings),
        'panduan': () => Get.toNamed(AppRoutes.panduan),
        'buka panduan': () => Get.toNamed(AppRoutes.panduan),
        'scroll': () => scrollBy(320),
        'scroll bawah': () => scrollBy(320),
        'scroll turun': () => scrollBy(320),
        'turun': () => scrollBy(320),
        'lanjut': () => scrollBy(320),
        'ke bawah': () => scrollBy(320),
        'scroll atas': () => scrollBy(-320),
        'naik': () => scrollBy(-320),
        'kembali ke atas': scrollToTop,
        'keluar': () async {
          if (await _confirmLogout(context)) {
            controller.logout();
          }
        },
        'logout': () async {
          if (await _confirmLogout(context)) {
            controller.logout();
          }
        },
      },
      child: Scaffold(
        backgroundColor: _bgWarm,
        body: Stack(
          children: [
            // ── Bubble dekoratif (konsisten dengan DashboardView) ─────────
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
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      controller: controller.scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          // Profile Card
                          GestureDetector(
                            onTap: controller.navigateToProfileSettings,
                            child: _buildProfileCard(),
                          ),

                          const SizedBox(height: 16),

                          // Statistics Cards
                          Obx(() => _buildStatRow()),

                          const SizedBox(height: 28),

                          // Kelola Akun Section
                          _buildSectionTitle('Kelola Akun'),
                          const SizedBox(height: 12),
                          _buildMenuItem(
                            icon: Icons.settings_rounded,
                            title: 'Pengaturan Profile',
                            onTap: controller.navigateToProfileSettings,
                            color: const Color(0xFF2196F3),
                          ),
                          const SizedBox(height: 10),
                          _buildMenuItem(
                            icon: Icons.info_rounded,
                            title: 'Tentang Kami',
                            onTap: controller.navigateToAboutUs,
                            color: const Color(0xFF00BCD4),
                          ),
                          const SizedBox(height: 10),
                          _buildMenuItem(
                            icon: Icons.help_outline_rounded,
                            title: 'Panduan',
                            onTap: () => Get.toNamed(AppRoutes.panduan),
                            color: const Color(0xFF8E24AA),
                          ),

                          const SizedBox(height: 24),

                          // Fitur Siswa Section
                          _buildSectionTitle('Fitur Siswa'),
                          const SizedBox(height: 12),
                          _buildMenuItem(
                            icon: Icons.quiz_rounded,
                            title: 'Kuis',
                            onTap: () {
                              Get.toNamed(AppRoutes.profileQuiz);
                            },
                            color: const Color(0xFF4CAF50),
                          ),
                          const SizedBox(height: 10),
                          _buildMenuItem(
                            icon: Icons.note_rounded,
                            title: 'Catatan',
                            onTap: () {
                              Get.toNamed(AppRoutes.profileNotes);
                            },
                            color: const Color(0xFF3F51B5),
                          ),
                          const SizedBox(height: 10),
                          _buildMenuItem(
                            icon: Icons.record_voice_over_rounded,
                            title: 'Pengaturan Suara',
                            onTap: () {
                              Get.toNamed(AppRoutes.profileVoiceSettings);
                            },
                            color: const Color(0xFFFF7043),
                          ),
                          const SizedBox(height: 10),
                          _buildMenuItem(
                            icon: Icons.logout_rounded,
                            title: 'Keluar',
                            onTap: () async {
                              if (await _confirmLogout(
                                  Get.context!)) {
                                controller.logout();
                              }
                            },
                            color: Colors.red,
                            isLogout: true,
                          ),

                          const SizedBox(height: 32),
                        ],
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

  // ── Header (konsisten dengan DashboardView _buildHeader) ──────────────────
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
              // Logo + brand (sama dengan dashboard)
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
                      Icons.pan_tool_rounded,
                      color: AppColors.orange,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Profil',
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
                        'Kelola akun & preferensi',
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

              // Voice button (sama dengan DashboardView)
              _VoicePulseButton(
                child: VoiceCommandButton(size: 44),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section title ─────────────────────────────────────────────────────────
  Widget _buildSectionTitle(String title) {
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

  // ── Profile Card ──────────────────────────────────────────────────────────
  Widget _buildProfileCard() {
    return Obx(() {
      final displayName =
          controller.isLoading.value &&
              controller.userName.value.trim().isEmpty
          ? 'Memuat profil...'
          : controller.userName.value.trim().isEmpty
          ? 'Nama belum tersedia'
          : controller.userName.value;
      final displayEmail =
          controller.isLoading.value &&
              controller.userEmail.value.trim().isEmpty
          ? 'Memuat email...'
          : controller.userEmail.value.trim();

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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFF7A00), Color(0xFFFFB02E)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.orange.withOpacity(0.22),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: controller.profileImageUrl.value.isEmpty
                      ? const Icon(Icons.person, size: 36, color: Colors.white)
                      : ClipOval(
                          child: Image.network(
                            controller.profileImageUrl.value,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.person,
                                    size: 36, color: Colors.white),
                          ),
                        ),
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.yellow.withOpacity(0.8), width: 2),
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        size: 13, color: AppColors.orange),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.4), width: 1),
                    ),
                    child: const Text(
                      'Akun Siswa',
                      style: TextStyle(
                        fontSize: 11,
                        height: 1,
                        color: Color(0xFF7B5A00),
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFB93D00),
                      fontFamily: 'Nunito',
                      height: 1.15,
                    ),
                  ),
                  if (displayEmail.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      displayEmail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF514000),
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  if (controller.isLoading.value)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  if (controller.errorMessage.value.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        controller.errorMessage.value,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Arrow
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.88),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE0B84A).withOpacity(0.4),
                    blurRadius: 0,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_forward_ios_rounded,
                  color: AppColors.orange, size: 16),
            ),
          ],
        ),
      );
    });
  }

  // ── Stat row ──────────────────────────────────────────────────────────────
  Widget _buildStatRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.check_circle_rounded,
            number: controller.completedMaterials.value.toString(),
            label: 'Selesai',
            subLabel: 'Materi',
            color: const Color(0xFF2E9E5B),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.access_time_rounded,
            number: controller.pendingMaterials.value.toString(),
            label: 'Menunggu',
            subLabel: 'Materi',
            color: const Color(0xFFE5A100),
          ),
        ),
      ],
    );
  }

  // ── Stat card ─────────────────────────────────────────────────────────────
  Widget _buildStatCard({
    required IconData icon,
    required String number,
    required String label,
    required String subLabel,
    required Color color,
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      number,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: _textDark,
                        fontFamily: 'Nunito',
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        subLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          color: _textGrey,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Menu item ─────────────────────────────────────────────────────────────
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color color,
    bool isLogout = false,
  }) {
    return GestureDetector(
      onTap: onTap,
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
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isLogout ? Colors.red : _textDark,
                  fontFamily: 'Nunito',
                ),
              ),
            ),
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
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: isLogout ? Colors.red : AppColors.orange,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmLogout(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi keluar'),
          content: const Text('Apakah kamu yakin ingin keluar dari akun ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
    return result ?? false;
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