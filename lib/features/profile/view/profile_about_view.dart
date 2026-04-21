import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/widgets/primary_header.dart';

class ProfileAboutView extends StatelessWidget {
  const ProfileAboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            PrimaryHeader(
              title: 'Tentang Kami',
              trailing: IconButton(
                onPressed: Get.back,
                icon: const Icon(Icons.close_rounded, color: AppColors.orange),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _aboutCard(),
                  const SizedBox(height: 16),
                  _visionCard(),
                  const SizedBox(height: 16),
                  _contactCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _aboutCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _title('Ruma'),
          SizedBox(height: 8),
          Text(
            'Aplikasi belajar tanpa sentuh untuk siswa tunadaksa. Kami menggabungkan gaze-tracking dan perintah suara agar navigasi materi lebih mudah dan inklusif.',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textBlack,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }

  Widget _visionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _title('Prinsip Desain'),
          SizedBox(height: 8),
          _bullet('Aksesibilitas dulu: semua kontrol bisa diakses tanpa sentuhan.'),
          _bullet('Umpan balik jelas: status gaze/mic selalu terlihat.'),
          _bullet('Privasi: kamera/mikrofon hanya aktif saat pengguna menyalakan mode bantuan.'),
        ],
      ),
    );
  }

  Widget _contactCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _title('Kontak'),
          SizedBox(height: 8),
          _bullet('Email: ruma-support@example.com'),
          _bullet('Telepon: 0800-123-456'),
          _bullet('Dukungan teknis: buka menu Panduan di Profil.'),
        ],
      ),
    );
  }

  BoxDecoration _box() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}

class _title extends StatelessWidget {
  final String text;
  const _title(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.textBlack,
        fontFamily: 'Roboto',
      ),
    );
  }
}

class _bullet extends StatelessWidget {
  final String text;
  const _bullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.brightness_1, size: 8, color: AppColors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textBlack,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
