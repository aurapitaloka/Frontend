import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/widgets/primary_header.dart';

class ProfileNotificationsView extends StatelessWidget {
  const ProfileNotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            PrimaryHeader(
              title: 'Notifikasi',
              trailing: IconButton(
                onPressed: Get.back,
                icon: const Icon(Icons.close_rounded, color: AppColors.orange),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _notice(
                    title: 'Materi baru tersedia',
                    desc: 'Bab "Pendidikan Agama Islam" sudah diperbarui.',
                    icon: Icons.menu_book_rounded,
                    color: const Color(0xFF4CAF50),
                    time: 'Baru saja',
                  ),
                  const SizedBox(height: 12),
                  _notice(
                    title: 'Pengingat belajar',
                    desc: 'Waktunya lanjutkan materi kelas 5.',
                    icon: Icons.access_time_rounded,
                    color: AppColors.orange,
                    time: '10 menit lalu',
                  ),
                  const SizedBox(height: 12),
                  _notice(
                    title: 'Notifikasi bantuan',
                    desc: 'Mode voice & gaze aktif saat membaca.',
                    icon: Icons.mic_none_rounded,
                    color: const Color(0xFF2196F3),
                    time: '1 jam lalu',
                  ),
                  const SizedBox(height: 12),
                  _notice(
                    title: 'Keamanan akun',
                    desc: 'Pastikan email/nomor aktif agar info penting tidak terlewat.',
                    icon: Icons.verified_user_rounded,
                    color: const Color(0xFF9C27B0),
                    time: 'Kemarin',
                  ),
                  const SizedBox(height: 12),
                  _notice(
                    title: 'Update aplikasi',
                    desc: 'Versi baru meningkatkan aksesibilitas membaca.',
                    icon: Icons.system_update_alt_rounded,
                    color: const Color(0xFF00BCD4),
                    time: '2 hari lalu',
                  ),
                  const SizedBox(height: 20),
                  _infoCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notice({
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textBlack,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.yellow, Color(0xFFFFF59D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.yellow.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.notifications_active_rounded, color: AppColors.orange),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Tips',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.orange,
                    fontFamily: 'Roboto',
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Jika mode gaze/voice aktif, tampilkan notifikasi singkat yang mudah dibaca dan bisa ditutup suara.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textBlack,
                    height: 1.4,
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
