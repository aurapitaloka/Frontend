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
        'notifikasi': controller.navigateToNotifications,
        'buka notifikasi': controller.navigateToNotifications,
        'tentang kami': controller.navigateToAboutUs,
        'tentang aplikasi': controller.navigateToAboutUs,
        'info aplikasi': controller.navigateToAboutUs,
        'kuis': () => Get.toNamed(AppRoutes.profileQuiz),
        'buka kuis': () => Get.toNamed(AppRoutes.profileQuiz),
        'catatan': () => Get.toNamed(AppRoutes.profileNotes),
        'buka catatan': () => Get.toNamed(AppRoutes.profileNotes),
        'pengaturan suara': () => Get.toNamed(AppRoutes.profileVoiceSettings),
        'setelan suara': () => Get.toNamed(AppRoutes.profileVoiceSettings),
        'buka pengaturan suara': () => Get.toNamed(AppRoutes.profileVoiceSettings),
        'aac': () => Get.toNamed(AppRoutes.aac),
        'komunikasi': () => Get.toNamed(AppRoutes.aac),
        'buka aac': () => Get.toNamed(AppRoutes.aac),
        'buka komunikasi': () => Get.toNamed(AppRoutes.aac),
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
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            controller: controller.scrollController,
            child: Column(
              children: [
                PrimaryHeader(
                  title: 'Profile',
                  trailing: const VoiceCommandButton(),
                ),
              const SizedBox(height: 18),

              const SizedBox(height: 24),

              // Profile Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
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
                  child: Obx(
                    () => Column(
                      children: [
                        // Profile Picture
                        Stack(
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.orange,
                                    AppColors.orange.withOpacity(0.7),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.orange.withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: controller.profileImageUrl.value.isEmpty
                                  ? const Icon(
                                      Icons.person,
                                      size: 45,
                                      color: Colors.white,
                                    )
                                  : ClipOval(
                                      child: Image.network(
                                        controller.profileImageUrl.value,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return const Icon(
                                                Icons.person,
                                                size: 45,
                                                color: Colors.white,
                                              );
                                            },
                                      ),
                                    ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.yellow,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 14,
                                  color: AppColors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Name
                        Text(
                          controller.userName.value,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textBlack,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          controller.userEmail.value,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontFamily: 'Roboto',
                          ),
                        ),
                        if (controller.isLoading.value)
                          const Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        if (controller.errorMessage.value.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              controller.errorMessage.value,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red[400],
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Statistics Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.check_circle_rounded,
                        number: controller.completedMaterials.value.toString(),
                        label: 'Materi',
                        subLabel: 'Terselesaikan',
                        color: const Color(0xFF4CAF50),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.access_time_rounded,
                        number: controller.pendingMaterials.value.toString(),
                        label: 'Materi',
                        subLabel: 'Menunggu',
                        color: const Color(0xFFFF9800),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Kelola Akun Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kelola Akun',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildMenuItem(
                      icon: Icons.settings_rounded,
                      title: 'Pengaturan Profile',
                      onTap: controller.navigateToProfileSettings,
                      color: const Color(0xFF2196F3),
                    ),
                    const SizedBox(height: 10),
                    _buildMenuItem(
                      icon: Icons.notifications_rounded,
                      title: 'Notifikasi',
                      onTap: controller.navigateToNotifications,
                      color: const Color(0xFF9C27B0),
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
                      icon: Icons.record_voice_over_rounded,
                      title: 'AAC (Komunikasi)',
                      onTap: () => Get.toNamed(AppRoutes.aac),
                      color: const Color(0xFFFF9800),
                    ),
                    const SizedBox(height: 10),
                    _buildMenuItem(
                      icon: Icons.help_outline_rounded,
                      title: 'Panduan',
                      onTap: () => Get.toNamed(AppRoutes.panduan),
                      color: const Color(0xFF8E24AA),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Fitur Siswa',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildMenuItem(
                      icon: Icons.quiz_rounded,
                      title: 'Kuis',
                      onTap: () {
                        Get.toNamed(
                          AppRoutes.profileQuiz,
                        );
                      },
                      color: const Color(0xFF4CAF50),
                    ),
                    const SizedBox(height: 10),
                    _buildMenuItem(
                      icon: Icons.note_rounded,
                      title: 'Catatan',
                      onTap: () {
                        Get.toNamed(
                          AppRoutes.profileNotes,
                        );
                      },
                      color: const Color(0xFF3F51B5),
                    ),
                    const SizedBox(height: 10),
                    _buildMenuItem(
                      icon: Icons.record_voice_over_rounded,
                      title: 'Pengaturan Suara',
                      onTap: () {
                        Get.toNamed(
                          AppRoutes.profileVoiceSettings,
                        );
                      },
                      color: const Color(0xFFFF7043),
                    ),
                    const SizedBox(height: 10),
                    _buildMenuItem(
                      icon: Icons.logout_rounded,
                      title: 'Keluar',
                      onTap: () async {
                        if (await _confirmLogout(context)) {
                          controller.logout();
                        }
                      },
                      color: Colors.red,
                      isLogout: true,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            number,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textBlack,
              fontFamily: 'Roboto',
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textBlack,
              fontFamily: 'Roboto',
            ),
          ),
          Text(
            subLabel,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

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
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isLogout ? Colors.red : AppColors.textBlack,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey[400],
              size: 22,
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
