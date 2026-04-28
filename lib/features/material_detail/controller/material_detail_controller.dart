import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:page_flip/page_flip.dart';
import '../../../routes/app_routes.dart';
import '../../../core/services/pdf_page_ocr_service.dart';
import '../../../core/services/rak_buku_service.dart';
import '../../../core/services/sesi_baca_service.dart';
import '../../../core/services/voice_guide_service.dart';
import '../../../core/controllers/voice_command_controller.dart';
import '../../rak_buku/controller/rak_buku_controller.dart';

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

  // ===============================
  // STATE
  // ===============================
  final RxBool inRak = false.obs;
  final RxBool gazeEnabled = false.obs;
  final RxBool voiceEnabled = false.obs;
  final RxBool isReadingPage = false.obs;
  final RxBool isProcessingOcr = false.obs;
  final RxBool showQuizCta = false.obs;
  final RxBool quizCtaUnlocked = false.obs;
  final RxBool isLastPageLoaded = false.obs;
  final RxList<String> textPages = <String>[].obs;
  final VoiceCommandController voiceCommandController =
      Get.find<VoiceCommandController>();

  final PageFlipController textFlipController = PageFlipController();
  Future<void> Function()? _nextPdfPage;
  Future<void> Function()? _previousPdfPage;

  /// dipakai view (FutureBuilder)

  /// halaman terakhir
  final RxInt lastSessionPage = 1.obs;
  int readerStartPage = 1;
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

    materiId = _parseId(args['materi_id']);
    fiksiId = _parseId(args['fiksi_id']);
    title = args['title'] ?? 'Judul Materi';
    subtitle = args['subtitle'] ?? '';
    category = args['category'] ?? '';
    coverImage =
        args['coverImage'] ??
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
      readerStartPage = lastSessionPage.value;
      isLastPageLoaded.value = true;
    });
    Future.microtask(enableVoiceOnOpen);
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
    Future.microtask(_refreshQuizCtaFromCurrentState);
  }

  void setTextPages(List<String> pages) {
    if (textPages.length == pages.length) {
      var unchanged = true;
      for (var i = 0; i < pages.length; i++) {
        if (textPages[i] != pages[i]) {
          unchanged = false;
          break;
        }
      }
      if (unchanged) return;
    }
    textPages.assignAll(pages);
  }

  Future<void> _loadLastPage() async {
    if (_storageKey == null) return;

    final prefs = await SharedPreferences.getInstance();
    lastSessionPage.value = prefs.getInt(_storageKey!) ?? 1;
  }

  // ===============================
  // TOGGLES
  // ===============================
  void toggleRak() {
    _toggleRakStatus();
  }

  Future<void> enableVoiceOnOpen() async {
    if (voiceEnabled.value) return;
    final res = await Permission.microphone.request();
    if (res.isGranted) {
      voiceEnabled.value = true;
      await voiceCommandController.startListening();
    }
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
    stopReadingPage();
    if (voiceEnabled.value) {
      voiceCommandController.stopListening();
      voiceEnabled.value = false;
    }
    clearPdfPageControls();
    super.onClose();
  }

  void registerPdfPageControls({
    required Future<void> Function() nextPage,
    required Future<void> Function() previousPage,
  }) {
    _nextPdfPage = nextPage;
    _previousPdfPage = previousPage;
  }

  void clearPdfPageControls() {
    _nextPdfPage = null;
    _previousPdfPage = null;
  }

  Future<void> nextPage() async {
    if (pdfUrl != null && pdfUrl!.isNotEmpty) {
      await _nextPdfPage?.call();
      return;
    }
    textFlipController.nextPage();
  }

  Future<void> previousPage() async {
    if (pdfUrl != null && pdfUrl!.isNotEmpty) {
      await _previousPdfPage?.call();
      return;
    }
    textFlipController.previousPage();
  }

  Future<void> readCurrentPageAloud() async {
    final url = pdfUrl;
    if (url == null || url.isEmpty) {
      final pageIndex = (lastSessionPage.value - 1).clamp(
        0,
        textPages.isEmpty ? 0 : textPages.length - 1,
      );
      final textPage = textPages.isEmpty ? '' : textPages[pageIndex].trim();
      if (textPage.isEmpty) {
        Get.snackbar(
          'Teks tidak tersedia',
          'Halaman materi teks belum siap dibacakan.',
        );
        return;
      }
      isReadingPage.value = true;
      try {
        await VoiceGuideService.instance.speak(textPage);
      } finally {
        isReadingPage.value = false;
      }
      return;
    }
    if (isProcessingOcr.value) return;

    isProcessingOcr.value = true;
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Gagal mengunduh PDF (${response.statusCode})');
      }

      final extractedText = await PdfPageOcrService.instance
          .extractTextFromPdfPage(
            pdfBytes: response.bodyBytes,
            pageNumber: lastSessionPage.value,
          );

      if (extractedText.isEmpty) {
        Get.snackbar(
          'Teks tidak ditemukan',
          'Halaman ini belum berhasil dibaca OCR. Coba halaman lain atau pastikan scan cukup jelas.',
        );
        return;
      }

      isReadingPage.value = true;
      await VoiceGuideService.instance.speak(extractedText);
      isReadingPage.value = false;
    } catch (e) {
      isReadingPage.value = false;
      Get.snackbar(
        'OCR gagal',
        'Tidak bisa membacakan halaman ini: $e',
      );
    } finally {
      isProcessingOcr.value = false;
    }
  }

  Future<void> stopReadingPage() async {
    isReadingPage.value = false;
    await VoiceGuideService.instance.stop();
  }

  Future<void> _loadRakStatus() async {
    if (materiId == null) return;
    try {
      final res = await RakBukuService.status(materiId!);
      if (res.containsKey('in_rak')) {
        inRak.value = res['in_rak'] == true;
      } else if (res['data'] is Map && res['data']['in_rak'] != null) {
        inRak.value = res['data']['in_rak'] == true;
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
      final statusCode = int.tryParse(res['_status_code']?.toString() ?? '');
      if (res.containsKey('error') ||
          res.containsKey('errors') ||
          (statusCode != null && statusCode >= 400)) {
        inRak.value = !next;
        Get.snackbar(
          'Rak Buku gagal diperbarui',
          res['message']?.toString() ?? res['error']?.toString() ?? 'Coba lagi.',
        );
        return;
      }
      if (Get.isRegistered<RakBukuController>()) {
        await Get.find<RakBukuController>().fetchItems();
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
        final last = int.tryParse(res['halaman_terakhir']?.toString() ?? '');
        if (last != null && last > lastSessionPage.value) {
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

  Future<void> _refreshQuizCtaFromCurrentState() async {
    if (materiId == null) return;
    if (_totalPages <= 0) {
      showQuizCta.value = false;
      return;
    }

    final currentPage = lastSessionPage.value.clamp(1, _totalPages);
    if (currentPage != lastSessionPage.value) {
      lastSessionPage.value = currentPage;
      await saveLastPage(currentPage);
    }

    final persen = ((currentPage / _totalPages) * 100).round();
    await _updateQuizCta(persen);
  }

  int get totalPages => _totalPages;

  Future<void> _updateQuizCta(int persen) async {
    if (materiId == null) return;
    if (quizCtaUnlocked.value) {
      showQuizCta.value = _isOnLastPage;
      return;
    }
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
    quizCtaUnlocked.value = true;
    showQuizCta.value = _isOnLastPage;
  }

  bool get _isOnLastPage {
    if (_totalPages <= 0) return false;
    return lastSessionPage.value >= _totalPages;
  }

  void goToQuizIntro() {
    if (materiId == null) return;
    Get.toNamed(
      AppRoutes.materiQuizIntro,
      arguments: {'materi_id': materiId, 'materi_title': title},
    );
  }

  bool get isFiksi => fiksiId != null;

  int? _parseId(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }
}
