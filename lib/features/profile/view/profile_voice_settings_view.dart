import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/widgets/primary_header.dart';

class ProfileVoiceSettingsView extends StatelessWidget {
  const ProfileVoiceSettingsView({super.key});

  static const Color _bgWarm = Color(0xFFFFF8F3);
  static const Color _borderSoft = Color(0xFFF0E8E0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgWarm,
      body: SafeArea(
        child: Column(
          children: [
            PrimaryHeader(
              title: 'Pengaturan Suara',
              trailing: IconButton(
                onPressed: Get.back,
                icon: const Icon(Icons.close_rounded, color: AppColors.orange),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                children: [
                  _tipCard(),
                  const SizedBox(height: 16),
                  _settingTile(
                    title: 'Mode suara otomatis',
                    subtitle: 'Aktifkan saat membaca materi.',
                    icon: Icons.mic_rounded,
                    color: const Color(0xFFFF7043),
                  ),
                  const SizedBox(height: 12),
                  _settingTile(
                    title: 'Kecepatan bicara',
                    subtitle: 'Sesuaikan tempo suara agar nyaman.',
                    icon: Icons.speed_rounded,
                    color: const Color(0xFF3F51B5),
                  ),
                  const SizedBox(height: 12),
                  _settingTile(
                    title: 'Volume narasi',
                    subtitle: 'Atur volume sesuai kebutuhan.',
                    icon: Icons.volume_up_rounded,
                    color: const Color(0xFF4CAF50),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tipCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF3E0), Color(0xFFFFF8E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderSoft),
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
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.record_voice_over_rounded,
                color: AppColors.orange),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Atur suara agar nyaman dan jelas saat materi diputar.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textBlack,
                height: 1.4,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderSoft),
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
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
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
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: Colors.grey[400], size: 22),
        ],
      ),
    );
  }
}
