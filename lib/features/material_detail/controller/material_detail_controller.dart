import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:page_flip/page_flip.dart';
import '../../../routes/app_routes.dart';
import '../../../core/services/rak_buku_service.dart';
import '../../../core/services/sesi_baca_service.dart';
import '../../../core/controllers/voice_command_controller.dart';

class MaterialDetailController extends GetxController {
  // ===============================
  // DATA MATERI
  // ===============================
  late final String title;
  late final String subtitle;
  late final String coverImage;
  late final String body;
  late final String category;

  String? pdfUrl;
  int? materiId;
  int? fiksiId;
  String? _storageKey;
  String? _quizPromptKey;
  bool _quizPromptedThisSession = false;

  // ===============================
  // STATE
  // ===============================
  final RxBool inRak = false.obs;
  final RxBool gazeEnabled = false.obs;
  final RxBool voiceEnabled = false.obs;
  final RxBool showQuizCta = false.obs;
  final VoiceCommandController voiceCommandController = Get.find<VoiceCommandController>();

  final PageFlipController textFlipController = PageFlipController();


  /// dipakai view (FutureBuilder)

  /// halaman terakhir
  final RxInt lastSessionPage = 1.obs;
  int _totalPages = 1;

  static const String _fallbackBody =
      'Ini adalah isi materi teks. Jika PDF tidak tersedia, teks ini akan ditampilkan.';

  // ===============================
  // INIT (AMBIL ARGUMENT SAJA)
  // ===============================
  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>? ?? {};

    materiId = args['materi_id'];
    fiksiId = args['fiksi_id'];
    title = args['title'] ?? 'Judul Materi';
    subtitle = args['subtitle'] ?? '';
    category = args['category'] ?? '';
    coverImage = args['coverImage'] ??
        'https://images.unsplash.com/photo-1521587760476-6c12a4b040da';
    body = args['body'] ?? _fallbackBody;

    pdfUrl = args['pdfUrl'];
    if (fiksiId != null) {
      _storageKey = 'fiksi_${fiksiId}_last_page';
    } else if (materiId != null) {
      _storageKey = 'materi_${materiId}_last_page';
      _quizPromptKey = 'materi_${materiId}_quiz_prompted';
    }

    if (materiId != null) {
      _loadRakStatus();
    }
  }

  // ===============================
  // READY (LOAD LAST PAGE)
  // ===============================
  @override
  void onReady() {
    super.onReady();

    _loadLastPage().then((_) async {
      if (materiId != null) {
        await _loadBackendLastPage();
      }
    });
  }

  // ===============================
  // SAVE & LOAD PAGE
  // ===============================
  Future<void> saveLastPage(int page) async {
    if (_storageKey == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_storageKey!, page);
  }

  void onPdfPageChanged(int page) {
    lastSessionPage.value = page;
    saveLastPage(page);
    _syncReadingSession(page);
  }

  void onTextPageChanged(int page, int totalPages) {
    _totalPages = totalPages;
    lastSessionPage.value = page;
    saveLastPage(page);
    _syncReadingSession(page);
  }

  void updateTotalPages(int totalPages) {
    _totalPages = totalPages;
  }

  Future<void> _loadLastPage() async {
    if (_storageKey == null) return;

    final prefs = await SharedPreferences.getInstance();
    lastSessionPage.value =
        prefs.getInt(_storageKey!) ?? 1;
  }

  // ===============================
  // TOGGLES
  // ===============================
  void toggleRak() {
    _toggleRakStatus();
  }

  Future<void> toggleGaze() async {
    if (!gazeEnabled.value) {
      final res = await Permission.camera.request();
      if (res.isGranted) gazeEnabled.value = true;
    } else {
      gazeEnabled.value = false;
    }
  }

  Future<void> toggleVoice() async {
    if (!voiceEnabled.value) {
      final res = await Permission.microphone.request();
      if (res.isGranted) {
        voiceEnabled.value = true;
        await voiceCommandController.startListening();
      }
    } else {
      voiceEnabled.value = false;
      await voiceCommandController.stopListening();
    }
  }

  // ===============================
  // CLEANUP
  // ===============================
  @override
  void onClose() {
    super.onClose();
  }

  Future<void> nextPage() async {
    if (pdfUrl != null && pdfUrl!.isNotEmpty) return;
    textFlipController.nextPage();
  }

  Future<void> previousPage() async {
    if (pdfUrl != null && pdfUrl!.isNotEmpty) return;
    textFlipController.previousPage();
  }

  Future<void> _loadRakStatus() async {
    if (materiId == null) return;
    try {
      final res = await RakBukuService.status(materiId!);
      if (res.containsKey('in_rak')) {
        inRak.value = res['in_rak'] == true;
      }
    } catch (_) {}
  }

  Future<void> _toggleRakStatus() async {
    if (materiId == null) return;
    final next = !inRak.value;
    inRak.value = next;
    try {
      final res = next
          ? await RakBukuService.addToRak(materiId!)
          : await RakBukuService.removeFromRak(materiId!);
      if (res.containsKey('error')) {
        inRak.value = !next;
      }
    } catch (_) {
      inRak.value = !next;
    }
  }

  Future<void> _loadBackendLastPage() async {
    if (materiId == null) return;
    try {
      final res = await SesiBacaService.getLast(materiId!);
      if (res.containsKey('halaman_terakhir')) {
        final last = res['halaman_terakhir'] as int?;
        if (last != null && last > 0) {
          lastSessionPage.value = last;
          await saveLastPage(last);
        }
      }
    } catch (_) {}
  }

  Future<void> _syncReadingSession(int page) async {
    if (materiId == null) return;
    if (_totalPages <= 0) return;
    final persen = ((page / _totalPages) * 100).round();
    try {
      await SesiBacaService.upsert({
        'materi_id': materiId,
        'halaman_terakhir': page,
        'progres_persen': persen,
      });
    } catch (_) {}
    await _updateQuizCta(persen);
  }

  int get totalPages => _totalPages;

  Future<void> _updateQuizCta(int persen) async {
    if (materiId == null) return;
    if (persen < 100) {
      showQuizCta.value = false;
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final wasPrompted = _quizPromptKey != null
        ? (prefs.getBool(_quizPromptKey!) ?? false)
        : false;
    if (!wasPrompted) {
      if (_quizPromptKey != null) {
        await prefs.setBool(_quizPromptKey!, true);
      }
    }
    _quizPromptedThisSession = true;
    showQuizCta.value = true;
  }

  void goToQuizIntro() {
    if (materiId == null) return;
    Get.toNamed(
      AppRoutes.materiQuizIntro,
      arguments: {
        'materi_id': materiId,
        'materi_title': title,
      },
    );
  }
}
