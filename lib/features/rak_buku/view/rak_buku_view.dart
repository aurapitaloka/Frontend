import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/rak_buku_controller.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/api_config.dart';
import '../../../core/widgets/primary_header.dart';
import '../../../core/widgets/voice_command_scope.dart';
import '../../../core/widgets/voice_command_button.dart';
import '../../../core/controllers/voice_command_controller.dart';
import '../../../routes/app_routes.dart';

class RakBukuView extends GetView<RakBukuController> {
  const RakBukuView({super.key});

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
                title: 'Rak Buku',
                trailing: VoiceCommandButton(),
              ),
              const SizedBox(height: 12),

            // List materi yang ada di Rak Buku (dari backend)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.error.value.isNotEmpty) {
                    return Center(child: Text(controller.error.value));
                  }
                  if (controller.items.isEmpty) {
                    return const Center(child: Text('Rak Buku kosong'));
                  }
                  return GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    controller: controller.scrollController,
                    itemCount: controller.items.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.55,
                    ),
                    itemBuilder: (context, index) {
                      final entry = controller.items[index];
                      final materi = entry['materi'] as Map<String, dynamic>? ?? {};
                      final title = materi['judul']?.toString() ?? 'Materi';
                      final subtitle = '${materi['level']?['nama'] ?? ''}';
                      final coverPath = materi['cover_path']?.toString();
                      final cover = ApiConfig.resolveStorageUrl(coverPath) ?? '';
                      final filePath = materi['file_path']?.toString();
                      final pdfUrl = ApiConfig.resolveStorageUrl(filePath);

                      return GestureDetector(
                        onTap: () {
                          Get.toNamed(
                            AppRoutes.materialDetail,
                            arguments: {
                              'title': title,
                              'subtitle': subtitle,
                              'category': 'Rak Buku',
                              'body': materi['konten_teks']?.toString() ?? '',
                              'coverImage': cover,
                              'pdfUrl': pdfUrl,
                              'materi_id': materi['id'],
                            },
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 180,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),

                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],

                                color: Colors.grey[200],
                                image: cover.isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(cover),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
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
      ),
    );
  }

  Widget _buildSubjectCard({required String name, required String iconName}) {
    IconData icon;
    Color iconColor;
    List<Color> gradientColors;

    switch (iconName) {
      case 'mosque_outlined':
        icon = Icons.mosque_outlined;
        iconColor = const Color(0xFF4CAF50);
        gradientColors = [const Color(0xFF81C784), const Color(0xFF66BB6A)];
        break;
      case 'language':
        icon = Icons.language;
        iconColor = const Color(0xFF2196F3);
        gradientColors = [const Color(0xFF64B5F6), const Color(0xFF42A5F5)];
        break;
      case 'translate':
        icon = Icons.translate;
        iconColor = const Color(0xFFFF9800);
        gradientColors = [const Color(0xFFFFB74D), const Color(0xFFFFA726)];
        break;
      case 'account_balance_outlined':
        icon = Icons.account_balance_outlined;
        iconColor = const Color(0xFF9C27B0);
        gradientColors = [const Color(0xFFBA68C8), const Color(0xFFAB47BC)];
        break;
      case 'language_outlined':
        icon = Icons.language_outlined;
        iconColor = const Color(0xFFF44336);
        gradientColors = [const Color(0xFFE57373), const Color(0xFFEF5350)];
        break;
      default:
        icon = Icons.book_outlined;
        iconColor = AppColors.orange;
        gradientColors = [AppColors.yellow, AppColors.yellow.withOpacity(0.8)];
    }

    return GestureDetector(
      onTap: () {
        Get.toNamed(
          AppRoutes.material,
          arguments: {
            'title': name,
            'subtitle': 'Semester Gasal | Mode akses tanpa sentuh',
            'category': 'Mata Pelajaran',
            'body': _sampleBody,
            'coverImage':
                'https://images.unsplash.com/photo-1521587760476-6c12a4b040da?auto=format&fit=crop&w=1200&q=80',
            'pdfUrl':
                'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
          },
        );
      },
      child: Column(
        children: [
          // Card dengan gradient dan shadow
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Background pattern (opsional untuk variasi)
                  Positioned(
                    right: -10,
                    top: -10,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    left: -5,
                    bottom: -5,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Icon utama
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 40, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Label mata pelajaran
          Text(
            name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textBlack,
              fontFamily: 'Roboto',
              height: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  static const String _sampleBody = '''
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec ligula ac justo faucibus malesuada. Sed dictum, nibh sit amet placerat gravida, velit mauris dapibus lacus, quis efficitur sapien nisl id urna. Mauris non massa non justo condimentum sodales. Curabitur a tortor eget magna fermentum mattis.

Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Nulla facilisi. Fusce lacinia, odio at accumsan bibendum, dolor ipsum congue arcu, sit amet aliquam turpis velit a felis. Suspendisse potenti. Praesent bibendum, risus a laoreet malesuada, magna dui fringilla dui, in interdum ex arcu ac mauris.
''';
}
