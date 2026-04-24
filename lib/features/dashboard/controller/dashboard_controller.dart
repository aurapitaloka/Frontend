import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/fiksi_service.dart';
import '../../../core/services/level_service.dart';
import '../../../core/services/materi_service.dart';
import '../../../core/services/sesi_baca_service.dart';
import '../../../core/services/voice_guide_service.dart';
import '../../../core/utils/api_config.dart';
import '../../../core/services/youtube_ai_service.dart';
import '../../youtube/view/youtube_result_view.dart';
import '../../../routes/app_routes.dart';
import '../../rak_buku/controller/rak_buku_controller.dart';

class DashboardController extends GetxController {
  // Selected index for bottom navigation
  final RxInt selectedIndex = 0.obs;

  // Active tab for home screen (Kelas or Fiksi)
  final RxString activeTab = 'Kelas'.obs;

  final RxnInt selectedLevelId = RxnInt();
  final RxString selectedLevelName = ''.obs;

  final RxList<Map<String, dynamic>> levels = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> materi = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> fiksi = <Map<String, dynamic>>[].obs;
  final RxInt lastSessionMateriId = RxInt(0);
  final RxString lastSessionMateriTitle = ''.obs;
  final RxInt lastSessionProgress = RxInt(0);
  final RxInt lastSessionPage = RxInt(0);
  final RxBool hasLastSession = false.obs;

  // Variabel baru untuk fitur YouTube
  final RxList<Map<String, dynamic>> youtubeVideos =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoadingYoutube = false.obs;
  final RxString youtubeSearchQuery =
      ''.obs; // Menyimpan teks yang diucapkan user
  final RxString youtubeErrorMessage = ''.obs;
  final TextEditingController searchController = TextEditingController();
  final ScrollController homeScrollController = ScrollController();
  final ScrollController youtubeScrollController = ScrollController();

  final RxBool isLoadingLevels = false.obs;
  final RxBool isLoadingMateri = false.obs;
  final RxBool isLoadingFiksi = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString fiksiErrorMessage = ''.obs;
  final RxString userName = 'Pengguna'.obs;
  final RxBool showGuideOnLoad = false.obs;
  bool _didPromptClassSelection = false;
  bool _guideShown = false;

  @override
  void onClose() {
    homeScrollController.dispose();
    youtubeScrollController.dispose();
    searchController.dispose();
    super.onClose();
  }

  List<Map<String, dynamic>> get currentItems {
    if (activeTab.value == 'Fiksi') {
      return fiksi;
    }
    final id = selectedLevelId.value;
    if (id == null || id <= 0) return materi;
    return materi.where((item) {
      // Try direct level_id first
      final levelId = item['level_id'];
      if (levelId is int) return levelId == id;
      if (levelId is String) {
        final parsed = int.tryParse(levelId);
        if (parsed != null) return parsed == id;
      }
      // Fallback to nested level object
      final levelObj = item['level'];
      if (levelObj is Map) {
        final nestedId = levelObj['id'];
        if (nestedId is int) return nestedId == id;
        if (nestedId is String) {
          final parsed = int.tryParse(nestedId);
          if (parsed != null) return parsed == id;
        }
      }
      return false;
    }).toList();
  }

  // Fungsi ini nanti dipanggil saat user selesai berbicara atau mengetik
  Future<void> searchYoutubeVideos(String query) async {
    if (query.trim().isEmpty) return;

    youtubeSearchQuery.value = query;
    youtubeErrorMessage.value = '';
    youtubeVideos.clear();
    isLoadingYoutube.value = true;
    Get.to(() => const YoutubeResultView());

    try {
      final videos = await YoutubeAiService.searchVideoWithAi(query);
      youtubeVideos.assignAll(videos);
    } catch (e) {
      youtubeErrorMessage.value = _friendlyYoutubeError(e);
    } finally {
      isLoadingYoutube.value = false;
    }
  }

  void searchYoutubeFromVoice(String spoken) {
    final query = _extractVoiceQuery(spoken);
    if (query.isEmpty) {
      youtubeErrorMessage.value =
          'Ucapan belum jelas. Coba ucapkan: "carikan video tentang matematika".';
      return;
    }
    searchController.text = query;
    searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: searchController.text.length),
    );
    searchYoutubeVideos(query);
  }

  void openMateriFromVoice(String spoken) {
    final query = _extractMateriQuery(spoken);
    if (query.isEmpty) {
      Get.snackbar(
        'Tidak jelas',
        'Sebutkan judul materinya. Contoh: "buka materi pecahan".',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final normalizedQuery = _normalize(query);
    Map<String, dynamic>? found;

    for (final item in materi) {
      final title = item['judul']?.toString() ?? '';
      if (title.isEmpty) continue;
      final normalizedTitle = _normalize(title);
      if (normalizedTitle.contains(normalizedQuery) ||
          normalizedQuery.contains(normalizedTitle)) {
        found = item;
        break;
      }
      final words = normalizedQuery
          .split(' ')
          .where((e) => e.isNotEmpty)
          .toList();
      if (words.isNotEmpty && words.every(normalizedTitle.contains)) {
        found = item;
        break;
      }
    }

    if (found == null) {
      Get.snackbar(
        'Materi tidak ditemukan',
        'Coba sebutkan judul yang lebih spesifik.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final kontenTeks = found['konten_teks']?.toString();
    final fileUrl = found['file_url']?.toString() ?? found['file_path']?.toString();
    final pdfUrl = resolveFileUrl(fileUrl);
    final coverSource =
        found['cover_url']?.toString() ?? found['cover_path']?.toString();
    final coverUrl = resolveFileUrl(coverSource);
    final title = found['judul']?.toString() ?? 'Materi';
    final semester = found['semester']?.toString() ?? '';

    Get.toNamed(
      AppRoutes.material,
      arguments: {
        'title': title,
        'subtitle': semester,
        'category': 'Mata Pelajaran',
        'body': kontenTeks?.isNotEmpty == true
            ? kontenTeks
            : 'Materi tidak tersedia.',
        'coverImage':
            coverUrl ??
            'https://images.unsplash.com/photo-1521587760476-6c12a4b040da?auto=format&fit=crop&w=1200&q=80',
        'pdfUrl': pdfUrl,
        'materi_id': found['id'],
      },
    );
  }

  String get selectedLevelLabel {
    if (selectedLevelName.value.isNotEmpty) {
      return selectedLevelName.value;
    }
    if (selectedLevelId.value != null) {
      if (selectedLevelId.value != null && selectedLevelId.value! > 0) {
        return 'Kelas ${selectedLevelId.value}';
      }
      return 'Semua';
    }
    return 'Kelas';
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map && args['showGuide'] == true) {
      showGuideOnLoad.value = true;
    }
    selectedLevelId.value = -1;
    selectedLevelName.value = 'Semua';
    fetchLevels();
    fetchProfile();
    fetchFiksi();
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Selamat Pagi';
    } else if (hour < 17) {
      return 'Selamat Siang';
    } else {
      return 'Selamat Malam';
    }
  }

  void changeIndex(int index) {
    selectedIndex.value = index;
    if (index == 1 && Get.isRegistered<RakBukuController>()) {
      Get.find<RakBukuController>().fetchItems();
    }
  }

  void changeTab(String tab) {
    activeTab.value = tab;
    if (tab == 'Fiksi' && fiksi.isEmpty && !isLoadingFiksi.value) {
      fetchFiksi();
    }
  }

  void changeLevel(int id, String name) {
    if (id <= 0) {
      selectedLevelId.value = -1;
      selectedLevelName.value = 'Semua';
    } else {
      selectedLevelId.value = id;
      selectedLevelName.value = name;
    }
    debugPrint(
      '[Dashboard] changeLevel -> id=$id, name=$name, baseUrl=${ApiConfig.baseUrl}',
    );
    fetchMateri(levelId: id > 0 ? id : null);
  }

  Future<void> fetchProfile() async {
    try {
      final response = await AuthService.getProfile();
      debugPrint('[Dashboard] fetchProfile response -> $response');
      final userCandidate = response['user'] ?? response;
      if (userCandidate is Map<String, dynamic>) {
        final name =
            userCandidate['nama']?.toString() ??
            userCandidate['name']?.toString();
        if (name != null && name.isNotEmpty) {
          userName.value = name;
        }
      }
    } catch (_) {}
  }

  String? resolveFileUrl(String? filePath) {
    return ApiConfig.resolveStorageUrl(filePath);
  }

  Future<void> fetchLevels() async {
    isLoadingLevels.value = true;
    errorMessage.value = '';
    try {
      debugPrint(
        '[Dashboard] fetchLevels -> endpoint=${ApiConfig.levelEndpoint}',
      );
      final response = await LevelService.getAll();
      debugPrint('[Dashboard] fetchLevels response -> $response');
      final list = _extractList(response);
      if (list != null) {
        levels.assignAll(list);
        _ensureSelectedLevel();
        _promptClassSelectionIfNeeded();
        // load materi after levels are available (default: all materi)
        await fetchMateri();
      } else {
        final statusCode = response['_status_code'] as int?;
        if (statusCode != 404) {
          errorMessage.value =
              response['message']?.toString() ??
              response['error']?.toString() ??
              'Gagal memuat level';
        }
      }
    } finally {
      isLoadingLevels.value = false;
    }
  }

  Future<void> fetchMateri({int? levelId}) async {
    isLoadingMateri.value = true;
    errorMessage.value = '';
    try {
      final useLevelId = levelId ?? selectedLevelId.value;
      final levelParam = (useLevelId != null && useLevelId > 0)
          ? useLevelId
          : null;
      debugPrint(
        '[Dashboard] fetchMateri -> endpoint=${ApiConfig.materiEndpoint}, levelId=$levelParam',
      );
      final response = await MateriService.getAll(
        perPage: 50,
        levelId: levelParam,
      );
      debugPrint('[Dashboard] fetchMateri response -> $response');
      final list = _extractList(response);
      if (list != null) {
        materi.assignAll(list);
        await fetchLatestReadingSession();
      } else {
        final statusCode = response['_status_code'] as int?;
        if (statusCode != 404) {
          errorMessage.value =
              response['message']?.toString() ??
              response['error']?.toString() ??
              'Gagal memuat materi';
        }
      }
    } finally {
      isLoadingMateri.value = false;
    }
  }

  Future<void> fetchFiksi({int? page, int? perPage}) async {
    isLoadingFiksi.value = true;
    fiksiErrorMessage.value = '';
    try {
      debugPrint(
        '[Dashboard] fetchFiksi -> endpoint=${ApiConfig.fiksiEndpoint}, page=$page',
      );
      final response = await FiksiService.getAll(
        page: page,
        perPage: perPage ?? 10,
      );
      debugPrint('[Dashboard] fetchFiksi response -> $response');
      final list = _extractList(response);
      if (list != null) {
        fiksi.assignAll(list);
      } else {
        final statusCode = response['_status_code'] as int?;
        if (statusCode != 404) {
          fiksiErrorMessage.value =
              response['message']?.toString() ??
              response['error']?.toString() ??
              'Gagal memuat fiksi';
        }
      }
    } finally {
      isLoadingFiksi.value = false;
    }
  }

  void _ensureSelectedLevel() {
    if (levels.isEmpty) return;
    final currentId = selectedLevelId.value;
    if (currentId == null ||
        currentId <= 0 ||
        levels.every((level) => _parseLevelId(level['id']) != currentId)) {
      selectedLevelId.value = -1;
      selectedLevelName.value = 'Semua';
    }
  }

  void _promptClassSelectionIfNeeded() {
    if (_didPromptClassSelection) return;
    if (levels.isEmpty) return;
    if (selectedLevelId.value != null) return;
    _didPromptClassSelection = true;
    Get.dialog(
      AlertDialog(
        title: const Text('Pilih Kelas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: levels.map((level) {
            final id = _parseLevelId(level['id']);
            final name = level['nama']?.toString() ?? 'Kelas';
            if (id == null) return const SizedBox.shrink();
            return ListTile(
              title: Text(name),
              onTap: () {
                changeLevel(id, name);
                Get.back();
              },
            );
          }).toList(),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // ─── REDESIGNED GUIDE POPUP ───────────────────────────────────────────────

  void showGuideIfNeeded() {
    if (!showGuideOnLoad.value || _guideShown) return;
    _guideShown = true;
    showGuideOnLoad.value = false;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: _GuideDialog(
          onClose: () {
            VoiceGuideService.instance.stop();
            Get.back();
          },
          onPlayAudio: _speakGuide,
          guideChipRowBuilder: _guideChipRow,
        ),
      ),
      barrierDismissible: true,
    );

    _speakGuide();
  }

  Widget _guideChipRow({required List<String> labels}) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: labels
          .map(
            (label) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8F0),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFCC80), width: 1),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF7B4F00),
                  letterSpacing: 0.1,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  void _speakGuide() {
    const guideText =
        'Selamat datang di Ruma. Gunakan tab bawah atau ucapkan dashboard, '
        'rak buku, atau profil untuk berpindah halaman. '
        'Untuk AAC/komunikasi, buka dari menu profil. '
        'Ucapkan kembali atau tutup untuk kembali. '
        'Ucapkan stop, berhenti, atau diam untuk menghentikan pendengaran. '
        'Saat membaca materi, ucapkan mulai membaca untuk mengaktifkan perintah, '
        'lalu gunakan lanjut, selanjutnya, atau halaman berikutnya, '
        'dan ucapkan sebelumnya untuk kembali.';
    VoiceGuideService.instance.speak(guideText);
  }

  // ─────────────────────────────────────────────────────────────────────────

  int? _parseLevelId(dynamic raw) {
    if (raw is int) return raw;
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  List<Map<String, dynamic>>? _extractList(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    if (data is Map && data['data'] is List) {
      return (data['data'] as List).cast<Map<String, dynamic>>();
    }
    return null;
  }

  Future<void> fetchLastSessionFor(int materiId) async {
    try {
      final res = await SesiBacaService.getLast(materiId);
      debugPrint('[Dashboard] getLastSession -> $res');
      if (res.containsKey('id')) {
        lastSessionPage.value = (res['halaman_terakhir'] as int?) ?? 0;
        lastSessionProgress.value = (res['progres_persen'] as int?) ?? 0;
      }
    } catch (e) {
      debugPrint('[Dashboard] getLastSession error -> $e');
    }
  }

  Future<void> fetchLatestReadingSession() async {
    hasLastSession.value = false;
    lastSessionMateriId.value = 0;
    lastSessionMateriTitle.value = '';
    lastSessionProgress.value = 0;
    lastSessionPage.value = 0;
    if (materi.isEmpty) return;

    final fromList = await _latestSessionFromList();
    if (fromList != null) {
      _applyLatestSession(fromList);
      return;
    }

    final fallback = await _latestSessionFromMateriChecks();
    if (fallback != null) {
      _applyLatestSession(fallback);
    }
  }

  Future<Map<String, dynamic>?> _latestSessionFromList() async {
    try {
      final res = await SesiBacaService.list(perPage: 50);
      debugPrint('[Dashboard] sesi list -> $res');
      final list = _extractList(res);
      if (list == null || list.isEmpty) return null;

      final sorted = [...list];
      sorted.sort((a, b) {
        final aTime = _sessionTime(a);
        final bTime = _sessionTime(b);
        return bTime.compareTo(aTime);
      });

      for (final session in sorted) {
        final materiId = _parseMateriIdFromSession(session);
        if (materiId == null || materiId <= 0) continue;
        final item = _materiById(materiId);
        if (item == null) continue;
        return {'session': session, 'materi': item, 'materi_id': materiId};
      }
    } catch (e) {
      debugPrint('[Dashboard] sesi list error -> $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> _latestSessionFromMateriChecks() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic>? best;
    var bestPage = 0;
    for (final item in materi) {
      final id = _parseInt(item['id']);
      if (id == null || id <= 0) continue;
      try {
        final res = await SesiBacaService.getLast(id);
        final page =
            _parseInt(res['halaman_terakhir']) ??
            prefs.getInt('materi_${id}_last_page') ??
            0;
        final progress = _parseInt(res['progres_persen']) ?? 0;
        if (page > 0 && page >= bestPage) {
          bestPage = page;
          best = {
            'session': {
              ...res,
              'halaman_terakhir': page,
              'progres_persen': progress,
            },
            'materi': item,
            'materi_id': id,
          };
        }
      } catch (_) {
        final page = prefs.getInt('materi_${id}_last_page') ?? 0;
        if (page > 0 && page >= bestPage) {
          bestPage = page;
          best = {
            'session': {'halaman_terakhir': page, 'progres_persen': 0},
            'materi': item,
            'materi_id': id,
          };
        }
      }
    }
    return best;
  }

  void _applyLatestSession(Map<String, dynamic> data) {
    final session = data['session'] as Map<String, dynamic>;
    final item = data['materi'] as Map<String, dynamic>;
    final id = _parseInt(data['materi_id']) ?? _parseInt(item['id']) ?? 0;
    if (id <= 0) return;

    hasLastSession.value = true;
    lastSessionMateriId.value = id;
    lastSessionMateriTitle.value = item['judul']?.toString() ?? '';
    lastSessionPage.value = _parseInt(session['halaman_terakhir']) ?? 0;
    lastSessionProgress.value = _parseInt(session['progres_persen']) ?? 0;
  }

  Map<String, dynamic>? _materiById(int id) {
    for (final item in materi) {
      if (_parseInt(item['id']) == id) return item;
    }
    return null;
  }

  int? _parseMateriIdFromSession(Map<String, dynamic> session) {
    final direct = _parseInt(session['materi_id']);
    if (direct != null) return direct;
    final materiObj = session['materi'];
    if (materiObj is Map) {
      return _parseInt(materiObj['id']) ?? _parseInt(materiObj['materi_id']);
    }
    return null;
  }

  DateTime _sessionTime(Map<String, dynamic> session) {
    final raw =
        session['updated_at'] ??
        session['terakhir_dibaca_at'] ??
        session['last_read_at'] ??
        session['created_at'] ??
        '';
    return DateTime.tryParse(raw.toString()) ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  int? _parseInt(dynamic raw) {
    if (raw is int) return raw;
    return int.tryParse(raw?.toString() ?? '');
  }

  String _friendlyYoutubeError(Object error) {
    final message = error.toString();
    if (message.contains('YOUTUBE_API_KEY')) {
      return 'API YouTube belum di-set. Isi `.env` atau tambahkan `--dart-define=YOUTUBE_API_KEY=...` saat run/build.';
    }
    if (message.contains('GROQ_API_KEY')) {
      return 'API GROQ belum di-set. Isi `.env` atau tambahkan `--dart-define=GROQ_API_KEY=...` saat run/build.';
    }
    return 'Gagal mencari video YouTube. Silakan coba lagi.';
  }

  String _extractVoiceQuery(String spoken) {
    var text = spoken.toLowerCase().trim();
    if (text.isEmpty) return '';

    text = text.replaceAll(RegExp(r'\bdg\b'), 'dengan');

    final prefixes = [
      'tolong carikan',
      'tolong cari',
      'carikan saya',
      'cariin saya',
      'cari materi berkaitan',
      'carikan materi berkaitan',
      'cari materi tentang',
      'carikan materi tentang',
      'carikan',
      'cariin',
      'cari',
      'cari video',
      'carikan video',
      'cari materi',
      'carikan materi',
      'cari youtube',
      'carikan youtube',
    ];
    for (final p in prefixes) {
      if (text.startsWith(p)) {
        text = text.substring(p.length).trim();
        break;
      }
    }

    // Buang kata penghubung umum di depan
    final leadingFillers = [
      'tentang',
      'mengenai',
      'yang',
      'materi',
      'video',
      'berkaitan',
      'berkaitan dengan',
      'terkait',
      'terkait dengan',
      'seputar',
      'dengan',
    ];
    for (final f in leadingFillers) {
      if (text.startsWith('$f ')) {
        text = text.substring(f.length).trim();
      }
    }

    // Buang akhiran umum
    final suffixes = ['di youtube', 'youtube', 'di yutub', 'yutub', 'ini'];
    for (final s in suffixes) {
      if (text.endsWith(' $s')) {
        text = text.substring(0, text.length - s.length).trim();
      }
    }

    // Rapikan spasi ganda
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return text;
  }

  String _extractMateriQuery(String spoken) {
    var text = spoken.toLowerCase().trim();
    if (text.isEmpty) return '';

    final prefixes = [
      'buka materi',
      'baca materi',
      'lihat materi',
      'materi',
      'buka',
      'baca',
      'lihat',
    ];
    for (final p in prefixes) {
      if (text.startsWith(p)) {
        text = text.substring(p.length).trim();
        break;
      }
    }

    final leadingFillers = ['tentang', 'yang', 'ini'];
    for (final f in leadingFillers) {
      if (text.startsWith('$f ')) {
        text = text.substring(f.length).trim();
      }
    }

    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return text;
  }

  String _normalize(String text) {
    final lowered = text.toLowerCase();
    final cleaned = lowered.replaceAll(RegExp(r'[^a-z0-9 ]'), ' ');
    return cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}

// ─── REDESIGNED GUIDE DIALOG WIDGET ─────────────────────────────────────────

class _GuideDialog extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onPlayAudio;
  final Widget Function({required List<String> labels}) guideChipRowBuilder;

  const _GuideDialog({
    required this.onClose,
    required this.onPlayAudio,
    required this.guideChipRowBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 16, 18),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFF8F00), Color(0xFFFFA726)],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.record_voice_over_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Panduan Singkat',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Perintah suara yang tersedia',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                // Close button
                GestureDetector(
                  onTap: onClose,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Body ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section: Navigasi
                _SectionLabel(
                  icon: Icons.navigation_rounded,
                  label: 'Navigasi Halaman',
                ),
                const SizedBox(height: 8),
                guideChipRowBuilder(
                  labels: const [
                    'dashboard / beranda',
                    'rak buku',
                    'profil / profile',
                    'aac / komunikasi',
                  ],
                ),
                const SizedBox(height: 6),
                guideChipRowBuilder(
                  labels: const ['kembali / tutup', 'stop / berhenti / diam'],
                ),

                const SizedBox(height: 16),

                // Divider
                Container(height: 1, color: const Color(0xFFF0F0F0)),

                const SizedBox(height: 16),

                // Section: Membaca
                _SectionLabel(
                  icon: Icons.menu_book_rounded,
                  label: 'Saat Membaca Materi',
                ),
                const SizedBox(height: 8),
                guideChipRowBuilder(
                  labels: const [
                    'mulai / mulai membaca',
                    'lanjut / selanjutnya',
                    'halaman berikutnya',
                    'sebelumnya',
                  ],
                ),
              ],
            ),
          ),

          // ── Footer ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onClose,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFF8F00),
                      side: const BorderSide(
                        color: Color(0xFFFFCC80),
                        width: 1.2,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Tutup',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onPlayAudio,
                    icon: const Icon(Icons.volume_up_rounded, size: 18),
                    label: const Text(
                      'Putar Suara',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8F00),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
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

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: const Color(0xFFFF8F00)),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF3D2B00),
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }
}
