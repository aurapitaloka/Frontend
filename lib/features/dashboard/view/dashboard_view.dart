import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/dashboard_controller.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/widgets/voice_command_scope.dart';
import '../../../core/widgets/voice_command_button.dart';
import '../../../core/controllers/voice_command_controller.dart';
import '../../../routes/app_routes.dart';

import '../../rak_buku/view/rak_buku_view.dart';
import '../../profile/view/profile_view.dart';
import '../../profile/binding/profile_binding.dart';
import '../../profile/controller/profile_controller.dart';
import '../../rak_buku/binding/rak_buku_binding.dart';
import '../../rak_buku/controller/rak_buku_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.showGuideIfNeeded();
    });

    void scrollHomeBy(double delta) {
      final c = controller.homeScrollController;
      if (!c.hasClients) return;
      final target = (c.offset + delta).clamp(0.0, c.position.maxScrollExtent);
      c.animateTo(
        target,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }

    void scrollHomeToTop() {
      final c = controller.homeScrollController;
      if (!c.hasClients) return;
      c.animateTo(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    }

    return VoiceCommandScope(
      commands: {
        'dashboard': () => controller.changeIndex(0),
        'beranda': () => controller.changeIndex(0),
        'rak buku': () => controller.changeIndex(1),
        'aac': () => Get.toNamed(AppRoutes.aac),
        'komunikasi': () => Get.toNamed(AppRoutes.aac),
        'profil': () => controller.changeIndex(2),
        'profile': () => controller.changeIndex(2),
        'buka profil': () => controller.changeIndex(2),
        'buka profile': () => controller.changeIndex(2),
        'notifikasi': () => Get.toNamed(AppRoutes.profileNotifications),
        'scroll': () => scrollHomeBy(320),
        'scroll bawah': () => scrollHomeBy(320),
        'scroll turun': () => scrollHomeBy(320),
        'turun': () => scrollHomeBy(320),
        'lanjut': () => scrollHomeBy(320),
        'ke bawah': () => scrollHomeBy(320),
        'scroll atas': () => scrollHomeBy(-320),
        'naik': () => scrollHomeBy(-320),
        'kembali ke atas': scrollHomeToTop,
        'carikan': () {
          final voice = Get.find<VoiceCommandController>();
          controller.searchYoutubeFromVoice(voice.lastWords.value);
        },
        'cari video': () {
          final voice = Get.find<VoiceCommandController>();
          controller.searchYoutubeFromVoice(voice.lastWords.value);
        },
        'carikan video': () {
          final voice = Get.find<VoiceCommandController>();
          controller.searchYoutubeFromVoice(voice.lastWords.value);
        },
        'cari materi': () {
          final voice = Get.find<VoiceCommandController>();
          controller.searchYoutubeFromVoice(voice.lastWords.value);
        },
        'carikan materi': () {
          final voice = Get.find<VoiceCommandController>();
          controller.searchYoutubeFromVoice(voice.lastWords.value);
        },
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
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: Obx(() => _getCurrentScreen()),
        bottomNavigationBar: Obx(() => _buildBottomNavigationBar()),
      ),
    );
  }

  Widget _getCurrentScreen() {
    switch (controller.selectedIndex.value) {
      case 1:
        if (!Get.isRegistered<RakBukuController>()) {
          RakBukuBinding().dependencies();
        }
        return const RakBukuView();
      case 2:
        return GetWidgetAacView();
      case 3:
        if (!Get.isRegistered<ProfileController>()) {
          ProfileBinding().dependencies();
        }
        return const ProfileView();
      default:
        return _buildHomeContent();
    }
  // Tambahkan widget pembungkus untuk AAC agar tidak menggunakan Get.toNamed di sini
  Widget GetWidgetAacView() {
    if (!Get.isRegistered<AacController>()) {
      AacBinding().dependencies();
    }
    return const AacView();
  }
  }

  Widget _buildHomeContent() {
    return SafeArea(
      child: Column(
        children: [
          // Top Header Section dengan gradient
          // Top Header Section - Professional & Clean Design
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: SafeArea(
    bottom: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        children: [
          // Top Bar: Logo & Notification
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo Section
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.yellow,
                          AppColors.yellow.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.yellow.withOpacity(0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
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
                        'AKSES',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.orange,
                          fontFamily: 'Roboto',
                          letterSpacing: 0.5,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Belajar Digital',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                          fontFamily: 'Roboto',
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              Row(
                children: [
                  const VoiceCommandButton(size: 38),
                  const SizedBox(width: 10),
                  _buildNotificationButton(),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Search Bar with Modern Design
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: TextField(
              controller: controller.searchController,
              onSubmitted: (value) {
                controller.searchYoutubeVideos(value);
              },
              decoration: InputDecoration(
                hintText: 'Cari mata pelajaran, buku, atau materi...',
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppColors.orange,
                  size: 24,
                ),
                suffixIcon: Container(
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    color: AppColors.orange,
                    size: 20,
                  ),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  ),
),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              controller: controller.homeScrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),

                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.yellow, Color(0xFFFFF59D)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.yellow.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                '📚 Lanjutkan Belajar',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.orange,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Obx(() => Text(
                            controller.lastSessionMateriTitle.value.isNotEmpty
                                ? controller.lastSessionMateriTitle.value
                                : 'Pendidikan Agama Islam',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.orange,
                              fontFamily: 'Roboto',
                              height: 1.2,
                            ),
                          )),
                          const SizedBox(height: 6),
                        Obx(() => Text(
                              controller.selectedLevelName.value.isNotEmpty
                                  ? controller.selectedLevelName.value
                                  : 'Kelas',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black.withOpacity(0.6),
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w500,
                              ),
                            )),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Obx(() => Text(
                                        '${controller.lastSessionProgress.value}% selesai',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black.withOpacity(0.7),
                                        ),
                                      )),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Obx(() {
                                      final factor = (controller.lastSessionProgress.value / 100).clamp(0.0, 1.0).toDouble();
                                      return FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: factor,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.orange,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.orange,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.orange.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  final id = controller.lastSessionMateriId.value;
                                  if (id == 0) return;
                                  final item = controller.materi.firstWhere(
                                    (m) => (m['id'] is int ? m['id'] == id : int.tryParse(m['id']?.toString() ?? '') == id),
                                    orElse: () => {},
                                  );
                                  if (item.isEmpty) return;
                                  final title = item['judul']?.toString() ?? controller.lastSessionMateriTitle.value;
                                  final levelName = (item['level'] as Map?)?['nama']?.toString() ?? controller.selectedLevelName.value;
                                  final filePath = item['file_path']?.toString();
                                  final pdfUrl = controller.resolveFileUrl(filePath);
                                  final coverPath = item['cover_path']?.toString();
                                  final coverUrl = controller.resolveFileUrl(coverPath);
                                  Get.toNamed(AppRoutes.material, arguments: {
                                    'title': title,
                                    'subtitle': levelName,
                                    'category': 'Mata Pelajaran',
                                    'body': item['konten_teks']?.toString() ?? '',
                                    'coverImage': coverUrl ??
                                        'https://images.unsplash.com/photo-1521587760476-6c12a4b040da?auto=format&fit=crop&w=1200&q=80',
                                    'pdfUrl': pdfUrl,
                                    'materi_id': id,
                                  });
                                },
                                icon: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                label: const Text(
                                  'Lanjut',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Start Reading Section
                  const Text(
                    'Yuk, Mulai Membaca',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                      fontFamily: 'Roboto',
                    ),
                  ),

                  const SizedBox(height: 8),

                  Obx(() {
                    final isKelas = controller.activeTab.value == 'Kelas';
                    final isLoadingLevels = controller.isLoadingLevels.value;
                    int? parseLevelId(dynamic raw) {
                      if (raw is int) return raw;
                      if (raw is String) return int.tryParse(raw);
                      return null;
                    }
                    final levelItems = <DropdownMenuItem<int>>[
                      const DropdownMenuItem<int>(
                        value: -1,
                        child: Text('Semua'),
                      ),
                      ...controller.levels
                          .map((level) {
                            final id = parseLevelId(level['id']);
                            if (id == null) return null;
                            final name =
                                level['nama']?.toString() ?? 'Kelas $id';
                            return DropdownMenuItem<int>(
                              value: id,
                              child: Text(name),
                            );
                          })
                          .whereType<DropdownMenuItem<int>>()
                          .toList(),
                    ];
                    final hasLevelItems = levelItems.isNotEmpty;

                    return Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          // ===== KELAS (DROPDOWN) =====
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color:
                                    isKelas ? AppColors.orange : Colors.white,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(14),
                                  bottomLeft: Radius.circular(14),
                                ),
                              ),
                              alignment: Alignment.center,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: hasLevelItems
                                      ? controller.selectedLevelId.value
                                      : null,
                                  isExpanded: true,
                                  hint: Text(
                                    isLoadingLevels
                                        ? 'Memuat kelas...'
                                        : (hasLevelItems
                                            ? 'Pilih Kelas'
                                            : 'Kelas belum tersedia'),
                                    style: TextStyle(
                                      color: isKelas
                                          ? Colors.white
                                          : AppColors.textBlack,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  icon: Icon(
                                    Icons.keyboard_arrow_down,
                                    color: isKelas
                                        ? Colors.white
                                        : AppColors.textBlack,
                                  ),
                                  dropdownColor: Colors.white,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  items: hasLevelItems
                                      ? levelItems
                                      : [
                                          DropdownMenuItem<int>(
                                            value: -1,
                                            enabled: false,
                                            child: Text(
                                              isLoadingLevels
                                                  ? 'Memuat kelas...'
                                                  : 'Kelas belum tersedia',
                                            ),
                                          ),
                                        ],
                                  onTap: () => controller.changeTab('Kelas'),
                                  onChanged: hasLevelItems
                                      ? (value) {
                                          if (value == null) return;

                                          final selected =
                                              controller.levels.firstWhere(
                                            (l) =>
                                                parseLevelId(l['id']) == value,
                                            orElse: () => {},
                                          );

                                          controller.changeTab('Kelas');
                                          controller.changeLevel(
                                            value,
                                            selected['nama']?.toString() ??
                                                'Kelas $value',
                                          );
                                        }
                                      : null,
                                ),
                              ),
                            ),
                          ),

                          Container(
                            width: 1,
                            color: Colors.grey.shade300,
                          ),

                          // ===== FIKSI =====
                          Expanded(
                            child: InkWell(
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(14),
                                bottomRight: Radius.circular(14),
                              ),
                              onTap: () => controller.changeTab('Fiksi'),
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: !isKelas
                                      ? AppColors.orange
                                      : Colors.white,
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(14),
                                    bottomRight: Radius.circular(14),
                                  ),
                                ),
                                child: Text(
                                  'Fiksi',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: !isKelas
                                        ? Colors.white
                                        : AppColors.textBlack,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),



                  const SizedBox(height: 16),

                  

                  const SizedBox(height: 8),

                  // Dropdown for class selection
                 

                  // Subject/Book List
                 Obx(() {
                    // 1. TAMPILAN UNTUK TAB YOUTUBE (PENCARIAN SUARA AI)
                    if (controller.activeTab.value == 'YouTube') {
                      if (controller.isLoadingYoutube.value) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Column(
                              children: [
                                CircularProgressIndicator(color: AppColors.orange),
                                SizedBox(height: 16),
                                Text("AI sedang mencarikan video yang tepat...", 
                                  style: TextStyle(fontFamily: 'Roboto', color: Colors.grey)),
                              ],
                            ),
                          ),
                        );
                      }

                      if (controller.youtubeVideos.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: Text("Video tidak ditemukan.")),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'Hasil Video untuk: "${controller.youtubeSearchQuery.value}"',
                              style: const TextStyle(
                                fontSize: 16, 
                                fontWeight: FontWeight.bold, 
                                color: AppColors.orange
                              ),
                            ),
                          ),
                          ...controller.youtubeVideos.map((video) {
                            return _buildYoutubeItem(video);
                          }).toList(),
                        ],
                      );
                    }

                    // 2. CEK LOADING UNTUK KELAS & FIKSI
                    if (controller.activeTab.value == 'Fiksi' && controller.isLoadingFiksi.value) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (controller.activeTab.value == 'Fiksi' && controller.fiksiErrorMessage.value.isNotEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(controller.fiksiErrorMessage.value, style: TextStyle(color: Colors.red[400], fontFamily: 'Roboto')),
                      );
                    }
                    if (controller.activeTab.value == 'Kelas' && controller.isLoadingMateri.value) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (controller.errorMessage.value.isNotEmpty && controller.activeTab.value == 'Kelas') {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(controller.errorMessage.value, style: TextStyle(color: Colors.red[400], fontFamily: 'Roboto')),
                      );
                    }

                    // 3. TAMPILAN LIST MATERI (KELAS) ATAU BUKU (FIKSI)
                    final items = controller.currentItems;
                    
                    if (controller.activeTab.value == 'Kelas' && items.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('Materi belum tersedia.', style: TextStyle(color: AppColors.textBlack, fontFamily: 'Roboto')),
                      );
                    }
                    if (controller.activeTab.value == 'Fiksi' && items.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('Buku fiksi belum tersedia.', style: TextStyle(color: AppColors.textBlack, fontFamily: 'Roboto')),
                      );
                    }

                    return Column(
                      children: items.map((item) {
                        if (controller.activeTab.value == 'Kelas') {
                          final title = item['judul']?.toString() ?? '';
                          final mataPelajaran = (item['mata_pelajaran'] as Map?)?['nama']?.toString() ?? 'Materi';
                          final levelName = (item['level'] as Map?)?['nama']?.toString() ?? controller.selectedLevelName.value;
                          final subtitle = levelName.isNotEmpty ? '$mataPelajaran | $levelName' : mataPelajaran;
                          final coverPath = (item['cover_path'] ?? item['cover_image'])?.toString();
                          final coverUrl = controller.resolveFileUrl(coverPath);
                          return _buildSubjectItem(
                            title: title,
                            semester: subtitle,
                            materi: item,
                            coverUrl: coverUrl,
                          );
                        } else {
                          final title = item['judul_buku']?.toString() ?? '';
                          final author = item['penulis']?.toString() ?? '';
                          final kategori = item['kategori']?.toString() ?? '';
                          final coverPath = (item['cover_path'] ?? item['cover_image'])?.toString();
                          final coverUrl = controller.resolveFileUrl(coverPath);
                          return _buildFictionBookItem(
                            title: title,
                            author: author,
                            category: kategori,
                            fiksi: item,
                            coverUrl: coverUrl,
                          );
                        }
                      }).toList(),
                    );
                  }),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab({
    required String rawLabel,
    required String labelText,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => controller.changeTab(rawLabel),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.orange : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.orange : Colors.grey.shade300,
            width: isSelected ? 0 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.orange.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected && rawLabel == 'Kelas')
              const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
                size: 20,
              ),
            if (isSelected && rawLabel == 'Kelas') const SizedBox(width: 4),
            Text(
              labelText,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textBlack,
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectItem({
    required String title,
    required String semester,
    required Map<String, dynamic> materi,
    String? coverUrl,
  }) {
    return GestureDetector(
      onTap: () {
        final kontenTeks = materi['konten_teks']?.toString();
        final filePath = materi['file_path']?.toString();
        final pdfUrl = controller.resolveFileUrl(filePath);
        final coverPath = materi['cover_path']?.toString();
        final coverUrl = controller.resolveFileUrl(coverPath);
        Get.toNamed(
          AppRoutes.material,
          arguments: {
            'title': title,
            'subtitle': semester,
            'category': 'Mata Pelajaran',
            'body': kontenTeks?.isNotEmpty == true ? kontenTeks : _detailBody,
            'coverImage': coverUrl ??
                'https://images.unsplash.com/photo-1521587760476-6c12a4b040da?auto=format&fit=crop&w=1200&q=80',
            'pdfUrl': pdfUrl,
            'materi_id': materi['id'],
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
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
        child: Row(
          children: [
            // Icon dengan gradient
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.yellow, AppColors.yellow.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: coverUrl != null && coverUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        coverUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.menu_book_rounded,
                          color: AppColors.orange,
                          size: 30,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.menu_book_rounded,
                      color: AppColors.orange,
                      size: 30,
                    ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textBlack,
                      fontFamily: 'Roboto',
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    semester,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.yellow.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.orange,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYoutubeItem(Map<String, dynamic> video) {
    return GestureDetector(
      onTap: () {
        // Logika untuk membuka pemutar video YouTube
        // Bisa menggunakan package youtube_player_flutter dan membukanya di halaman baru
        debugPrint("Buka Video: ${video['videoId']}");
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail Video (Besar agar mudah dilihat dengan mata)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Image.network(
                video['thumbnailUrl'],
                width: double.infinity,
                height: 200, // Ukuran besar untuk visibilitas
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video['title'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.smart_display_rounded, color: AppColors.orange, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        video['channelTitle'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFictionBookItem({
    required String title,
    required String author,
    required String category,
    required Map<String, dynamic> fiksi,
    String? coverUrl,
  }) {
    return GestureDetector(
      onTap: () {
        final description = fiksi['deskripsi']?.toString();
        final filePath = fiksi['file_path']?.toString();
        final pdfUrl = controller.resolveFileUrl(filePath);
        final coverPath = fiksi['cover_path']?.toString();
        final coverUrl = controller.resolveFileUrl(coverPath);
        Get.toNamed(
          AppRoutes.material,
          arguments: {
            'title': title,
            'subtitle': category.isNotEmpty
                ? 'Fiksi | $category'
                : 'Fiksi | $author',
            'category': 'Buku Fiksi',
            'body': description?.isNotEmpty == true ? description : _detailBody,
            'coverImage': coverUrl ??
                'https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&w=1200&q=80',
            'pdfUrl': pdfUrl,
            'fiksi_id': fiksi['id'],
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
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
        child: Row(
          children: [
            // Icon dengan gradient
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.yellow, AppColors.yellow.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: coverUrl != null && coverUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        coverUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.auto_stories_rounded,
                          color: AppColors.orange,
                          size: 30,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.auto_stories_rounded,
                      color: AppColors.orange,
                      size: 30,
                    ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textBlack,
                      fontFamily: 'Roboto',
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    author,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.yellow.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.orange,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isSelected: controller.selectedIndex.value == 0,
                onTap: () => controller.changeIndex(0),
              ),
              _buildNavItem(
                icon: Icons.library_books_rounded,
                label: 'Rak Buku',
                isSelected: controller.selectedIndex.value == 1,
                onTap: () => controller.changeIndex(1),
              ),
              _buildNavItem(
                icon: Icons.record_voice_over_rounded,
                label: 'AAC',
                isSelected: controller.selectedIndex.value == 2,
                onTap: () => controller.changeIndex(2),
              ),
              _buildNavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                isSelected: controller.selectedIndex.value == 3,
                onTap: () => controller.changeIndex(3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.yellow : Colors.transparent,
              shape: BoxShape.circle,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.yellow.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              icon,
              color: isSelected ? AppColors.orange : Colors.grey[600],
              size: 26,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? AppColors.orange : Colors.grey[600],
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Get.toNamed(AppRoutes.profileNotifications),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.orange,
                size: 22,
              ),
              Positioned(
                top: 9,
                right: 10,
                child: Container(
                  width: 8,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const String _detailBody = '''
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec ligula ac justo faucibus malesuada. Sed dictum, nibh sit amet placerat gravida, velit mauris dapibus lacus, quis efficitur sapien nisl id urna. Mauris non massa non justo condimentum sodales. Curabitur a tortor eget magna fermentum mattis.

Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Nulla facilisi. Fusce lacinia, odio at accumsan bibendum, dolor ipsum congue arcu, sit amet aliquam turpis velit a felis. Suspendisse potenti. Praesent bibendum, risus a laoreet malesuada, magna dui fringilla dui, in interdum ex arcu ac mauris. Phasellus congue, lacus vitae pulvinar vulputate, massa nisi aliquet libero, non hendrerit augue velit at enim.
''';
}
