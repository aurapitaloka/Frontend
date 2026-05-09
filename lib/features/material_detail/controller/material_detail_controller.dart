import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:page_flip/page_flip.dart';
import '../../../routes/app_routes.dart';
import '../../../core/services/bab_summary_service.dart';
import '../../../core/services/pdf_page_ocr_service.dart';
import '../../../core/services/rak_buku_service.dart';
import '../../../core/services/sesi_baca_service.dart';
import '../../../core/services/voice_guide_service.dart';
import '../../../core/controllers/voice_command_controller.dart';
import '../../rak_buku/controller/rak_buku_controller.dart';

class MaterialDetailController extends GetxController {
  static const String _voiceNoSpeechPrompt =
      'Saya belum mendengar perintah. Coba ulangi perintah suara untuk halaman ini.';
  // ===============================
  // DATA MATERI
  // ===============================
  late final String title;
  late final String subtitle;
  late final String chapterTitle;
  late final String coverImage;
  late final String body;
  late final String category;
  late final List<Map<String, dynamic>> chapterList;

  String? pdfUrl;
  int? materiId;
  int? babId;
  int? fiksiId;
  String? _storageKey;
  String? _quizPromptKey;
  Map<String, dynamic>? chapterQuiz;
  Uint8List? _cachedPdfBytes;
  int? _cachedOcrPage;
  String? _cachedOcrText;

  // ===============================
  // STATE
  // ===============================
  final RxBool inRak = false.obs;
  final RxBool gazeEnabled = false.obs;
  final RxBool voiceEnabled = false.obs;
  final RxBool isReadingPage = false.obs;
  final RxBool isProcessingOcr = false.obs;
  final RxBool isGeneratingSummary = false.obs;
  final RxBool showSummaryPage = false.obs;
  final RxBool showQuizCta = false.obs;
  final RxBool quizCtaUnlocked = false.obs;
  final RxBool isLastPageLoaded = false.obs;
  final RxList<String> textPages = <String>[].obs;
  final RxList<String> speechPages = <String>[].obs;
  final RxMap<String, dynamic> chapterSummary = <String, dynamic>{}.obs;
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

  static const String _fallbackBody = '';
  static const List<String> _bodyPlaceholderMarkers = <String>[
    'lorem ipsum dolor sit amet',
    'vestibulum ante ipsum primis',
    'ini adalah isi materi teks. jika pdf tidak tersedia',
  ];

  // ===============================
  // INIT (AMBIL ARGUMENT SAJA)
  // ===============================
  @override
  void onInit() {
    super.onInit();
    voiceCommandController.pushNoSpeechPrompt(_voiceNoSpeechPrompt);

    final args = Get.arguments as Map<String, dynamic>? ?? {};

    materiId = _parseId(args['materi_id']);
    babId = _parseId(args['bab_id']);
    fiksiId = _parseId(args['fiksi_id']);
    title = args['title'] ?? 'Judul Materi';
    subtitle = args['subtitle'] ?? '';
    chapterTitle = args['chapter_title']?.toString() ?? title;
    category = args['category'] ?? '';
    coverImage =
        args['coverImage'] ??
        'https://images.unsplash.com/photo-1521587760476-6c12a4b040da';
    body = args['body'] ?? _fallbackBody;
    chapterList = _parseChapterList(args['bab_list']);

    pdfUrl = args['pdfUrl'];
    chapterQuiz = _extractQuiz(args['chapter_quiz']);
    chapterSummary.assignAll(_extractSummary(args['chapter_summary'] ?? args));
    speechPages.assignAll(_buildSpeechPages(body));
    if (fiksiId != null) {
      _storageKey = 'fiksi_${fiksiId}_last_page';
    } else if (materiId != null) {
      _storageKey = babId != null
          ? 'materi_${materiId}_bab_${babId}_last_page'
          : 'materi_${materiId}_last_page';
      _quizPromptKey = babId != null
          ? 'materi_${materiId}_bab_${babId}_quiz_prompted'
          : 'materi_${materiId}_quiz_prompted';
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
      if (materiId != null && babId == null) {
        await _loadBackendLastPage();
      }
      readerStartPage = lastSessionPage.value < 1 ? 1 : lastSessionPage.value;
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
    if (_totalPages <= 0) {
      showSummaryPage.value = false;
      Future.microtask(_refreshQuizCtaFromCurrentState);
      return;
    }

    final normalizedPage = lastSessionPage.value.clamp(1, _totalPages);
    final normalizedStartPage = readerStartPage.clamp(1, _totalPages);
    final shouldSaveNormalizedPage = normalizedPage != lastSessionPage.value;

    if (shouldSaveNormalizedPage) {
      lastSessionPage.value = normalizedPage;
    }
    if (normalizedStartPage != readerStartPage) {
      readerStartPage = normalizedStartPage;
    }
    if (showSummaryPage.value && normalizedPage < _totalPages) {
      showSummaryPage.value = false;
    }

    Future.microtask(() async {
      if (shouldSaveNormalizedPage) {
        await saveLastPage(normalizedPage);
      }
      await _refreshQuizCtaFromCurrentState();
    });
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
      await voiceCommandController.ensureContinuousListening();
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
        await voiceCommandController.ensureContinuousListening();
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
    voiceCommandController.popNoSpeechPrompt(_voiceNoSpeechPrompt);
    voiceEnabled.value = false;
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
    if (showSummaryPage.value) return;
    if (_shouldOpenSummaryPage) {
      showSummaryPage.value = true;
      return;
    }
    if (pdfUrl != null && pdfUrl!.isNotEmpty) {
      await _nextPdfPage?.call();
      return;
    }
    textFlipController.nextPage();
  }

  Future<void> previousPage() async {
    if (showSummaryPage.value) {
      showSummaryPage.value = false;
      return;
    }
    if (pdfUrl != null && pdfUrl!.isNotEmpty) {
      await _previousPdfPage?.call();
      return;
    }
    textFlipController.previousPage();
  }

  Future<void> readCurrentPageAloud() async {
    final preparedText = _spokenTextForCurrentPage();
    if (preparedText.isNotEmpty) {
      isReadingPage.value = true;
      try {
        await VoiceGuideService.instance.speakLongText(preparedText);
      } finally {
        isReadingPage.value = false;
      }
      return;
    }

    final url = pdfUrl;
    if (url == null || url.isEmpty) {
      Get.snackbar(
        'Teks tidak tersedia',
        'Halaman materi teks belum siap dibacakan.',
      );
      return;
    }
    if (isProcessingOcr.value) return;

    if (_cachedOcrPage == lastSessionPage.value &&
        _cachedOcrText != null &&
        _cachedOcrText!.trim().isNotEmpty) {
      isReadingPage.value = true;
      try {
        await VoiceGuideService.instance.speakLongText(_cachedOcrText!);
      } finally {
        isReadingPage.value = false;
      }
      return;
    }

    isProcessingOcr.value = true;
    try {
      final pdfBytes = _cachedPdfBytes ?? await (() async {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw Exception('Gagal mengunduh PDF (${response.statusCode})');
        }
        _cachedPdfBytes = response.bodyBytes;
        return response.bodyBytes;
      })();

      if (pdfBytes.isEmpty) {
        throw Exception('File PDF kosong atau gagal dimuat.');
      }

      final extractedText = await PdfPageOcrService.instance
          .extractTextFromPdfPage(
            pdfBytes: pdfBytes,
            pageNumber: lastSessionPage.value,
          );

      if (extractedText.isEmpty) {
        Get.snackbar(
          'Teks tidak ditemukan',
          'Halaman ini belum berhasil dibaca OCR. Coba halaman lain atau pastikan scan cukup jelas.',
        );
        return;
      }

      _cachedOcrPage = lastSessionPage.value;
      _cachedOcrText = extractedText;
      isReadingPage.value = true;
      await VoiceGuideService.instance.speakLongText(extractedText);
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
    return lastSessionPage.value == _totalPages;
  }

  void goToQuizIntro() {
    final directQuizId = _parseId(
      chapterQuiz?['id'] ??
          chapterQuiz?['kuis_id'] ??
          chapterQuiz?['quiz_id'],
    );
    if (directQuizId != null && directQuizId > 0) {
      Get.toNamed(
        AppRoutes.profileQuizDetail,
        arguments: {
          'kuis_id': directQuizId,
          if (materiId != null) 'materi_id': materiId,
        },
      );
      return;
    }
    if (materiId == null) return;
    Get.toNamed(
      AppRoutes.materiQuizIntro,
      arguments: {'materi_id': materiId, 'materi_title': title},
    );
  }

  bool get hasChapters => chapterList.isNotEmpty;

  int get currentChapterIndex {
    final raw = Get.arguments?['selected_bab_index'];
    final parsed = _parseId(raw) ?? 0;
    if (chapterList.isEmpty) return 0;
    return parsed.clamp(0, chapterList.length - 1);
  }

  bool get hasNextChapter => currentChapterIndex < chapterList.length - 1;

  bool get hasPreviousChapter => currentChapterIndex > 0;

  bool get hasChapterQuiz => chapterQuiz != null;
  bool get hasSummaryFlow => hasChapterSummary || canGenerateSummary;

  bool get canGenerateSummary =>
      materiId != null && materiId! > 0 && babId != null && babId! > 0;

  bool get hasChapterSummary => chapterSummary.isNotEmpty;

  String get summaryTitle {
    final title = chapterSummary['summary_title']?.toString().trim() ?? '';
    return title.isNotEmpty ? title : 'Rangkuman Bab';
  }

  String get summaryShort =>
      chapterSummary['summary_short']?.toString().trim() ?? '';

  List<String> get summaryKeyPoints {
    final raw = chapterSummary['summary_key_points'];
    if (raw is List) {
      return raw.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
    }
    return const <String>[];
  }

  List<String> get summaryKeywords {
    final raw = chapterSummary['summary_keywords'];
    if (raw is List) {
      return raw.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
    }
    return const <String>[];
  }

  String get summaryMemoryTip =>
      chapterSummary['summary_memory_tip']?.toString().trim() ?? '';

  String get summaryExample =>
      chapterSummary['summary_example']?.toString().trim() ?? '';

  Future<void> generateChapterSummary() async {
    if (!canGenerateSummary || isGeneratingSummary.value) return;
    isGeneratingSummary.value = true;
    try {
      final res = await BabSummaryService.generateSummary(
        materiId: materiId!,
        babId: babId!,
      );
      if (res.containsKey('error')) {
        Get.snackbar(
          'Generate rangkuman gagal',
          res['message']?.toString() ?? res['error']?.toString() ?? 'Coba lagi.',
        );
        return;
      }
      final detail = _extractBabDetail(res);
      final summary = _extractSummary(detail.isNotEmpty ? detail : res);
      if (summary.isEmpty) {
        Get.snackbar(
          'Rangkuman belum tersedia',
          'Backend tidak mengembalikan field rangkuman untuk bab ini.',
        );
        return;
      }
      chapterSummary.assignAll(summary);
      showSummaryPage.value = true;
      Get.snackbar(
        'Berhasil',
        res['message']?.toString() ?? 'Rangkuman bab berhasil dibuat.',
      );
    } catch (e) {
      Get.snackbar('Generate rangkuman gagal', e.toString());
    } finally {
      isGeneratingSummary.value = false;
    }
  }

  Future<void> openChapterAt(int index) async {
    if (index < 0 || index >= chapterList.length) return;
    final chapter = chapterList[index];
    final nextQuiz = _extractQuiz(
      chapter['kuis'] ?? chapter['chapter_quiz'] ?? chapter,
    );
    if (materiId != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('materi_${materiId}_last_bab_index', index);
      final nextBabId = _parseId(chapter['id']);
      if (nextBabId != null && nextBabId > 0) {
        await prefs.setInt('materi_${materiId}_last_bab_id', nextBabId);
      }
    }

    await Get.offNamed(
      AppRoutes.materialDetail,
      arguments: {
        'materi_id': materiId,
        'bab_id': _parseId(chapter['id']),
        'selected_bab_index': index,
        'bab_list': chapterList,
        'chapter_title':
            chapter['judul_bab']?.toString() ??
            chapter['judul']?.toString() ??
            'Bab ${index + 1}',
        'title': title,
        'subtitle': subtitle,
        'category': category,
        'coverImage': coverImage,
        'body':
            chapter['konten_teks']?.toString() ??
            chapter['ringkasan']?.toString() ??
            chapter['isi']?.toString() ??
            '',
        'pdfUrl':
            chapter['file_url']?.toString() ??
            chapter['file_path']?.toString() ??
            chapter['pdf_url']?.toString(),
        'chapter_quiz': nextQuiz,
        'chapter_summary': _extractSummary(chapter),
      },
    );
  }

  Future<void> openNextChapter() async {
    if (!hasNextChapter) return;
    await openChapterAt(currentChapterIndex + 1);
  }

  Future<void> openPreviousChapter() async {
    if (!hasPreviousChapter) return;
    await openChapterAt(currentChapterIndex - 1);
  }

  bool get isFiksi => fiksiId != null;

  bool get _shouldOpenSummaryPage {
    if (showSummaryPage.value) return false;
    if (!hasSummaryFlow) return false;
    if (_totalPages <= 0) return false;
    return lastSessionPage.value == _totalPages;
  }

  int? _parseId(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  String _spokenTextForCurrentPage() {
    if (_shouldUsePdfOcrOnly) {
      return '';
    }

    final pages = textPages.isNotEmpty ? textPages : speechPages;
    if (pages.isEmpty) return '';

    final pageIndex = (lastSessionPage.value - 1).clamp(0, pages.length - 1);
    final pageText = _sanitizeSpeechText(pages[pageIndex]);
    if (pageText.isNotEmpty) return pageText;

    return _sanitizeSpeechText(body);
  }

  List<String> _buildSpeechPages(String source) {
    final cleaned = _sanitizeSpeechText(source);
    if (cleaned.isEmpty || _isPlaceholderBody(cleaned)) {
      return const <String>[];
    }

    final paragraphs = cleaned
        .split(RegExp(r'\n\s*\n'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    if (paragraphs.isEmpty) return [cleaned];

    final pages = <String>[];
    var current = '';

    void pushCurrent() {
      if (current.trim().isEmpty) return;
      pages.add(current.trim());
      current = '';
    }

    for (final paragraph in paragraphs) {
      final next = current.isEmpty ? paragraph : '$current\n\n$paragraph';
      if (next.length <= 500) {
        current = next;
      } else {
        pushCurrent();
        if (paragraph.length <= 500) {
          current = paragraph;
          continue;
        }
        final sentences = paragraph
            .split(RegExp(r'(?<=[.!?])\s+'))
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty);
        for (final sentence in sentences) {
          final sentenceNext = current.isEmpty ? sentence : '$current $sentence';
          if (sentenceNext.length <= 500) {
            current = sentenceNext;
          } else {
            pushCurrent();
            current = sentence;
          }
        }
      }
    }

    pushCurrent();
    return pages.isEmpty ? [cleaned] : pages;
  }

  String _sanitizeSpeechText(String source) {
    return source
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p\s*>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  bool get _shouldUsePdfOcrOnly {
    final hasPdf = pdfUrl != null && pdfUrl!.isNotEmpty;
    if (!hasPdf) return false;
    return _isPlaceholderBody(body);
  }

  bool _isPlaceholderBody(String source) {
    final normalized = _sanitizeSpeechText(source).toLowerCase();
    if (normalized.isEmpty) return true;
    return _bodyPlaceholderMarkers.any(normalized.contains);
  }

  List<Map<String, dynamic>> _parseChapterList(dynamic raw) {
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    return const <Map<String, dynamic>>[];
  }

  Map<String, dynamic>? _extractQuiz(dynamic raw) {
    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      final id = _parseId(map['id'] ?? map['kuis_id'] ?? map['quiz_id']);
      if (id != null && id > 0) return map;
    }
    return null;
  }

  Map<String, dynamic> _extractBabDetail(Map<String, dynamic> res) {
    final data = res['data'];
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }

  Map<String, dynamic> _extractSummary(dynamic raw) {
    if (raw is! Map) return <String, dynamic>{};
    final map = Map<String, dynamic>.from(raw);
    final summary = <String, dynamic>{};
    const keys = <String>[
      'summary_title',
      'summary_short',
      'summary_key_points',
      'summary_keywords',
      'summary_memory_tip',
      'summary_example',
      'summary_generated_at',
    ];
    for (final key in keys) {
      if (map[key] != null) {
        summary[key] = map[key];
      }
    }
    return summary;
  }
}
