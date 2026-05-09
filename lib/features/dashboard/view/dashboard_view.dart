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
import '../../aac/binding/aac_binding.dart';
import '../../aac/controller/aac_controller.dart';
import '../../aac/view/aac_view.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  static const Color _bgWarm    = Color(0xFFFFF8F3);
  static const Color _borderSoft = Color(0xFFF0E8E0);
  static const Color _textDark  = Color(0xFF1A1A2E);
  static const Color _textGrey  = Color(0xFF888888);
  static const Color _hintGrey  = Color(0xFFCCCCCC);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.showGuideIfNeeded();
    });

    void scrollHomeBy(double delta) {
      final c = controller.homeScrollController;
      if (!c.hasClients) return;
      final target =
          (c.offset + delta).clamp(0.0, c.position.maxScrollExtent);
      c.animateTo(target,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }

    void scrollHomeToTop() {
      final c = controller.homeScrollController;
      if (!c.hasClients) return;
      c.animateTo(0,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut);
    }

    return VoiceCommandScope(
      commands: {
        'dashboard':            () => controller.changeIndex(0),
        'beranda':              () => controller.changeIndex(0),
        'menu dashboard':       () => controller.changeIndex(0),
        'buka dashboard':       () => controller.changeIndex(0),
        'buka menu dashboard':  () => controller.changeIndex(0),
        'rak buku':             () => controller.changeIndex(1),
        'menu rak buku':        () => controller.changeIndex(1),
        'buka rak buku':        () => controller.changeIndex(1),
        'buka menu rak buku':   () => controller.changeIndex(1),
        'aac':                  () => controller.changeIndex(2),
        'komunikasi':           () => controller.changeIndex(2),
        'menu aac':             () => controller.changeIndex(2),
        'menu komunikasi':      () => controller.changeIndex(2),
        'buka aac':             () => controller.changeIndex(2),
        'buka komunikasi':      () => controller.changeIndex(2),
        'buka menu aac':        () => controller.changeIndex(2),
        'buka menu komunikasi': () => controller.changeIndex(2),
        'aac komunikasi':       () => controller.changeIndex(2),
        'buka aac komunikasi':  () => controller.changeIndex(2),
        'profil':               () => controller.changeIndex(3),
        'profile':              () => controller.changeIndex(3),
        'menu profil':          () => controller.changeIndex(3),
        'menu profile':         () => controller.changeIndex(3),
        'buka profil':          () => controller.changeIndex(3),
        'buka profile':         () => controller.changeIndex(3),
        'buka menu profil':     () => controller.changeIndex(3),
        'buka menu profile':    () => controller.changeIndex(3),
        'scroll':               () => scrollHomeBy(320),
        'scroll bawah':         () => scrollHomeBy(320),
        'scroll turun':         () => scrollHomeBy(320),
        'turun':                () => scrollHomeBy(320),
        'lanjut':               () => scrollHomeBy(320),
        'ke bawah':             () => scrollHomeBy(320),
        'scroll atas':          () => scrollHomeBy(-320),
        'naik':                 () => scrollHomeBy(-320),
        'kembali ke atas':      scrollHomeToTop,
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
        backgroundColor: _bgWarm,
        body: Obx(() => _getCurrentScreen()),
        bottomNavigationBar: Obx(() => _buildBottomNavigationBar()),
      ),
    );
  }

  // ── Screen switcher ───────────────────────────────────────────────────────
  Widget _getCurrentScreen() {
    switch (controller.selectedIndex.value) {
      case 1:
        if (!Get.isRegistered<RakBukuController>()) {
          RakBukuBinding().dependencies();
        }
        return const RakBukuView();
      case 2:
        return _getAacView();
      case 3:
        if (!Get.isRegistered<ProfileController>()) {
          ProfileBinding().dependencies();
        }
        return const ProfileView();
      default:
        return _buildHomeContent();
    }
  }

  Widget _getAacView() {
    if (!Get.isRegistered<AacController>()) {
      AacBinding().dependencies();
    }
    return const AacView();
  }

  // ── HOME ──────────────────────────────────────────────────────────────────
  Widget _buildHomeContent() {
    return Stack(
      children: [
        // ── Bubble dekoratif (konsisten dengan LoginView) ─────────────────
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

        // ── Konten utama ─────────────────────────────────────────────────
        SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  controller: controller.homeScrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Obx(() => _buildContinueReadingCard()),
                      const SizedBox(height: 28),
                      _buildSectionTitle('Yuk, Mulai Membaca 📚'),
                      const SizedBox(height: 12),
                      Obx(() => _buildTabSelector()),
                      const SizedBox(height: 16),
                      Obx(() => _buildContentList()),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
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
          child: Column(
            children: [
              // ── Logo row ───────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo + brand
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
                            'Ruma',
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
                            'Belajar Tanpa Batas',
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

                  // Voice button (sama persis gaya LoginView)
                  _VoicePulseButton(
                    child: VoiceCommandButton(size: 44),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // ── Search bar (gaya input LoginView) ─────────────────────
              Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _borderSoft, width: 2),
                ),
                child: TextField(
                  controller: controller.searchController,
                  onSubmitted: controller.searchYoutubeVideos,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Cari materi, buku, atau pelajaran...',
                    hintStyle: const TextStyle(
                      color: _hintGrey,
                      fontSize: 15,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w600,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: _hintGrey,
                      size: 22,
                    ),
                    suffixIcon: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.mic_rounded,
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

  // ── Tab selector ──────────────────────────────────────────────────────────
  Widget _buildTabSelector() {
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
        child: Text('Semua', style: TextStyle(fontFamily: 'Nunito')),
      ),
      ...controller.levels.map((level) {
        final id = parseLevelId(level['id']);
        if (id == null) return null;
        final name = level['nama']?.toString() ?? 'Kelas $id';
        return DropdownMenuItem<int>(
          value: id,
          child: Text(name, style: const TextStyle(fontFamily: 'Nunito')),
        );
      }).whereType<DropdownMenuItem<int>>().toList(),
    ];
    final hasLevelItems = levelItems.isNotEmpty;

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderSoft, width: 2),
      ),
      child: Row(
        children: [
          // ── Kelas (dropdown) ─────────────────────────────────────────
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isKelas ? AppColors.orange : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: hasLevelItems
                      ? controller.selectedLevelId.value
                      : null,
                  isExpanded: true,
                  hint: Text(
                    isLoadingLevels
                        ? 'Memuat...'
                        : (hasLevelItems
                            ? 'Pilih Kelas'
                            : 'Belum tersedia'),
                    style: TextStyle(
                      color: isKelas ? Colors.white : _textDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: isKelas ? Colors.white : AppColors.orange,
                    size: 22,
                  ),
                  dropdownColor: Colors.white,
                  style: const TextStyle(
                    color: _textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Nunito',
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
                                  : 'Belum tersedia',
                              style: const TextStyle(fontFamily: 'Nunito'),
                            ),
                          ),
                        ],
                  onTap: () => controller.changeTab('Kelas'),
                  onChanged: hasLevelItems
                      ? (value) {
                          if (value == null) return;
                          final selected = controller.levels.firstWhere(
                            (l) => parseLevelId(l['id']) == value,
                            orElse: () => {},
                          );
                          controller.changeTab('Kelas');
                          controller.changeLevel(
                            value,
                            selected['nama']?.toString() ?? 'Kelas $value',
                          );
                        }
                      : null,
                ),
              ),
            ),
          ),

          Container(width: 1.5, color: _borderSoft),

          // ── Fiksi ────────────────────────────────────────────────────
          Expanded(
            child: GestureDetector(
              onTap: () => controller.changeTab('Fiksi'),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: !isKelas ? AppColors.orange : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.auto_stories_rounded,
                      size: 18,
                      color: !isKelas ? Colors.white : AppColors.orange,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Fiksi',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: !isKelas ? Colors.white : _textDark,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Content list ──────────────────────────────────────────────────────────
  Widget _buildContentList() {
    // YouTube tab
    if (controller.activeTab.value == 'YouTube') {
      if (controller.isLoadingYoutube.value) {
        return _buildLoadingState('AI sedang mencarikan video yang tepat...');
      }
      if (controller.youtubeVideos.isEmpty) {
        return _buildEmptyState('Video tidak ditemukan.', Icons.videocam_off_rounded);
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoBanner(
            'Hasil video: "${controller.youtubeSearchQuery.value}"',
            Icons.play_circle_fill_rounded,
          ),
          const SizedBox(height: 12),
          ...controller.youtubeVideos
              .map((v) => _buildYoutubeItem(v))
              .toList(),
        ],
      );
    }

    // Loading states
    if (controller.activeTab.value == 'Fiksi' &&
        controller.isLoadingFiksi.value) {
      return _buildLoadingState('Memuat buku fiksi...');
    }
    if (controller.activeTab.value == 'Fiksi' &&
        controller.fiksiErrorMessage.value.isNotEmpty) {
      return _buildErrorState(controller.fiksiErrorMessage.value);
    }
    if (controller.activeTab.value == 'Kelas' &&
        controller.isLoadingMateri.value) {
      return _buildLoadingState('Memuat materi belajar...');
    }
    if (controller.errorMessage.value.isNotEmpty &&
        controller.activeTab.value == 'Kelas') {
      return _buildErrorState(controller.errorMessage.value);
    }

    // Item list
    final items = controller.currentItems;
    if (controller.activeTab.value == 'Kelas' && items.isEmpty) {
      return _buildEmptyState('Materi belum tersedia.', Icons.menu_book_rounded);
    }
    if (controller.activeTab.value == 'Fiksi' && items.isEmpty) {
      return _buildEmptyState('Buku fiksi belum tersedia.', Icons.auto_stories_rounded);
    }

    return Column(
      children: items.map((item) {
        if (controller.activeTab.value == 'Kelas') {
          final title = item['judul']?.toString() ?? '';
          final mataPelajaran =
              (item['mata_pelajaran'] as Map?)?['nama']?.toString() ??
              'Materi';
          final levelName =
              (item['level'] as Map?)?['nama']?.toString() ??
              controller.selectedLevelName.value;
          final subtitle = levelName.isNotEmpty
              ? '$mataPelajaran • $levelName'
              : mataPelajaran;
          final coverUrl = controller.resolveFileUrl(
              (item['cover_url'] ?? item['cover_image'])?.toString());
          return _buildSubjectItem(
            title: title,
            subtitle: subtitle,
            materi: item,
            coverUrl: coverUrl,
          );
        } else {
          final title =
              (item['judul_buku'] ?? item['judul'] ?? item['nama_buku'])
                      ?.toString() ??
                  '';
          final author =
              (item['penulis'] ?? item['author'] ?? 'Penulis').toString();
          final kategori = item['kategori']?.toString() ?? '';
          final coverUrl = controller.resolveFileUrl(
              (item['cover_url'] ?? item['cover_image'])?.toString());
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
  }

  // ── State helpers (loading / empty / error) ───────────────────────────────
  Widget _buildLoadingState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
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
      padding: const EdgeInsets.symmetric(vertical: 32),
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.withOpacity(0.2), width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 20),
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
    );
  }

  Widget _buildInfoBanner(String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD166), width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.orange, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: _textGrey,
                fontWeight: FontWeight.w700,
                fontFamily: 'Nunito',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Continue reading card ─────────────────────────────────────────────────
  Widget _buildContinueReadingCard() {
    final hasSession = controller.hasLastSession.value;
    final title =
        hasSession && controller.lastSessionMateriTitle.value.isNotEmpty
            ? controller.lastSessionMateriTitle.value
            : 'Pilih materi bacaan';
    final progress =
        hasSession ? controller.lastSessionProgress.value.clamp(0, 100) : 0;
    final progressFactor = (progress / 100).clamp(0.0, 1.0).toDouble();
    final level = controller.selectedLevelName.value.isNotEmpty
        ? controller.selectedLevelName.value
        : 'Semua';

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 140),
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
          // ── Badge + icon ──────────────────────────────────────────────
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
                child: Text(
                  hasSession ? '📖 Lanjut belajar' : '🚀 Mulai belajar',
                  style: const TextStyle(
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
                  Icons.auto_stories_rounded,
                  size: 18,
                  color: Color(0xFFC14900),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Title + button ────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
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
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.school_rounded,
                            size: 15, color: Color(0xFF755300)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            hasSession
                                ? level
                                : 'Belum ada riwayat terakhir',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF514000),
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: hasSession
                    ? _openLastSessionMateri
                    : _scrollToReadingList,
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hasSession
                            ? Icons.play_arrow_rounded
                            : Icons.arrow_downward_rounded,
                        size: 20,
                        color: AppColors.orange,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        hasSession ? 'Lanjut' : 'Pilih',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFC14900),
                          fontFamily: 'Nunito',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Progress bar ──────────────────────────────────────────────
          Row(
            children: [
              Text(
                hasSession ? 'Progress membaca' : 'Belum dimulai',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF514000),
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '$progress%',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9B3A00),
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 10,
              width: double.infinity,
              color: const Color(0xFFF5C400).withOpacity(0.42),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progressFactor,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _scrollToReadingList() {
    if (!controller.homeScrollController.hasClients) return;
    controller.homeScrollController.animateTo(
      360,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _openLastSessionMateri() async {
    final id = controller.lastSessionMateriId.value;
    if (id == 0) return;
    final item = controller.materi.firstWhere(
      (m) => (m['id'] is int
          ? m['id'] == id
          : int.tryParse(m['id']?.toString() ?? '') == id),
      orElse: () => {},
    );
    if (item.isEmpty) return;
    final title =
        item['judul']?.toString() ?? controller.lastSessionMateriTitle.value;
    final levelName =
        (item['level'] as Map?)?['nama']?.toString() ??
        controller.selectedLevelName.value;
    final pdfUrl =
        controller.resolveFileUrl(item['file_url']?.toString());
    final coverUrl =
        controller.resolveFileUrl(item['cover_url']?.toString());
    await Get.toNamed(
      AppRoutes.material,
      arguments: {
        'title': title,
        'subtitle': levelName,
        'category': 'Mata Pelajaran',
        'body': item['konten_teks']?.toString() ?? '',
        'coverImage': coverUrl ??
            'https://images.unsplash.com/photo-1521587760476-6c12a4b040da?auto=format&fit=crop&w=1200&q=80',
        'pdfUrl': pdfUrl,
        'materi_id': id,
      },
    );
    await controller.fetchLatestReadingSession();
  }

  // ── Subject item (Kelas) ──────────────────────────────────────────────────
  Widget _buildSubjectItem({
    required String title,
    required String subtitle,
    required Map<String, dynamic> materi,
    String? coverUrl,
  }) {
    return GestureDetector(
      onTap: () async {
        final kontenTeks = materi['konten_teks']?.toString();
        final pdfUrl =
            controller.resolveFileUrl(materi['file_url']?.toString());
        final cover =
            controller.resolveFileUrl(materi['cover_url']?.toString());
        await Get.toNamed(
          AppRoutes.material,
          arguments: {
            'title': title,
            'subtitle': subtitle,
            'category': 'Mata Pelajaran',
            'body': kontenTeks?.isNotEmpty == true ? kontenTeks : _detailBody,
            'coverImage': cover ??
                'https://images.unsplash.com/photo-1521587760476-6c12a4b040da?auto=format&fit=crop&w=1200&q=80',
            'pdfUrl': pdfUrl,
            'materi_id': materi['id'],
          },
        );
        await controller.fetchLatestReadingSession();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
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
            // Cover / icon
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: AppColors.yellow.withOpacity(0.35),
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
                  : const Icon(Icons.menu_book_rounded,
                      color: AppColors.orange, size: 30),
            ),
            const SizedBox(width: 14),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
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
                    style: const TextStyle(
                      fontSize: 13,
                      color: _textGrey,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w600,
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
    );
  }

  // ── Fiction book item ─────────────────────────────────────────────────────
  Widget _buildFictionBookItem({
    required String title,
    required String author,
    required String category,
    required Map<String, dynamic> fiksi,
    String? coverUrl,
  }) {
    return GestureDetector(
      onTap: () {
        final description =
            (fiksi['deskripsi'] ?? fiksi['sinopsis'] ?? fiksi['konten_teks'] ??
                fiksi['isi'])?.toString();
        final fileSource =
            (fiksi['file_url'] ?? fiksi['file'] ?? fiksi['pdf_path'] ??
                fiksi['path_file'] ?? fiksi['url'])?.toString();
        final pdfUrl = controller.resolveFileUrl(fileSource);
        final cover = controller.resolveFileUrl(
            (fiksi['cover_url'] ?? fiksi['cover_image'])?.toString());
        Get.toNamed(
          AppRoutes.materialDetail,
          arguments: {
            'title': title,
            'subtitle': category.isNotEmpty
                ? 'Fiksi • $category'
                : 'Fiksi • $author',
            'category': 'Buku Fiksi',
            'body': description?.isNotEmpty == true ? description : _detailBody,
            'coverImage': cover ??
                'https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&w=1200&q=80',
            'pdfUrl': pdfUrl,
            'fiksi_id': fiksi['id'],
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover buku (lebih besar untuk anak)
            Container(
              width: 80,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.yellow.withOpacity(0.35),
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
                          size: 36,
                        ),
                      ),
                    )
                  : const Icon(Icons.auto_stories_rounded,
                      color: AppColors.orange, size: 36),
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
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: _textDark,
                      fontFamily: 'Nunito',
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _textGrey,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  if (category.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
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
            const SizedBox(width: 8),
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
    );
  }

  // ── YouTube item ──────────────────────────────────────────────────────────
  Widget _buildYoutubeItem(Map<String, dynamic> video) {
    return GestureDetector(
      onTap: () {
        final videoId = video['videoId']?.toString();
        if (videoId == null || videoId.isEmpty) return;
        Get.toNamed(
          AppRoutes.webview,
          arguments: {
            'title': 'YouTube',
            'url': 'https://www.youtube.com/watch?v=$videoId',
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
              child: Image.network(
                video['thumbnailUrl'],
                width: double.infinity,
                height: 190,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video['title'],
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.smart_display_rounded,
                          color: AppColors.orange, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          video['channelTitle'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: _textGrey,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w600,
                          ),
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

  // ── Bottom navigation bar ─────────────────────────────────────────────────
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        border: Border(top: BorderSide(color: _borderSoft, width: 1.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.orange.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_rounded,
                label: 'Beranda',
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.library_books_rounded,
                label: 'Rak Buku',
                index: 1,
              ),
              _buildNavItem(
                icon: Icons.record_voice_over_rounded,
                label: 'AAC',
                index: 2,
              ),
              _buildNavItem(
                icon: Icons.person_rounded,
                label: 'Profil',
                index: 3,
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
    required int index,
  }) {
    final isSelected = controller.selectedIndex.value == index;
    return GestureDetector(
      onTap: () => controller.changeIndex(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              height: 42,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.yellow : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.yellow.withOpacity(0.6),
                          blurRadius: 0,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.orange : const Color(0xFFCCCCCC),
                size: 26,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                    isSelected ? FontWeight.w900 : FontWeight.w600,
                color: isSelected ? AppColors.orange : const Color(0xFFCCCCCC),
                fontFamily: 'Nunito',
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  static const String _detailBody = '''
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec ligula ac justo faucibus malesuada. Sed dictum, nibh sit amet placerat gravida, velit mauris dapibus lacus, quis efficitur sapien nisl id urna. Mauris non massa non justo condimentum sodales. Curabitur a tortor eget magna fermentum mattis.

Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Nulla facilisi. Fusce lacinia, odio at accumsan bibendum, dolor ipsum congue arcu, sit amet aliquam turpis velit a felis.
''';
}

// ── Voice pulse button (identik dengan LoginView) ─────────────────────────────
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
