import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:page_flip/page_flip.dart';
import 'package:http/http.dart' as http;
import 'package:pdfx/pdfx.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/widgets/voice_command_scope.dart';
import '../../../core/controllers/voice_command_controller.dart';
import '../controller/material_detail_controller.dart';

class MaterialDetailView extends GetView<MaterialDetailController> {
  const MaterialDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final voice = Get.find<VoiceCommandController>();
    return VoiceCommandScope(
      commands: {
        'mulai': voice.startListening,
        'mulai membaca': voice.startListening,
        'lanjut': controller.nextPage,
        'halaman berikutnya': controller.nextPage,
        'selanjutnya': controller.nextPage,
        'kembali': controller.previousPage,
        'sebelumnya': controller.previousPage,
        'bacakan halaman': controller.readCurrentPageAloud,
        'baca halaman': controller.readCurrentPageAloud,
        'bacakan teks': controller.readCurrentPageAloud,
        'baca teks': controller.readCurrentPageAloud,
        'stop baca': controller.stopReadingPage,
        'hentikan bacaan': controller.stopReadingPage,
        'tambah ke perpustakaan': () {
          if (!controller.inRak.value) {
            controller.toggleRak();
          }
        },
        'masukkan ke perpustakaan': () {
          if (!controller.inRak.value) {
            controller.toggleRak();
          }
        },
        'masukkan ke rak': () {
          if (!controller.inRak.value) {
            controller.toggleRak();
          }
        },
        'hapus dari perpustakaan': () {
          if (controller.inRak.value) {
            controller.toggleRak();
          }
        },
        'bab berikutnya': controller.openNextChapter,
        'bab selanjutnya': controller.openNextChapter,
        'bab sebelumnya': controller.openPreviousChapter,
        'mulai kuis': controller.goToQuizIntro,
        'buka kuis bab': controller.goToQuizIntro,
        'keluarkan dari rak': () {
          if (controller.inRak.value) {
            controller.toggleRak();
          }
        },
        'stop': voice.stopListening,
        'berhenti': voice.stopListening,
      },
      child: WillPopScope(
        onWillPop: () => _confirmExit(context),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: const Color(0xFFFFF9F1),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  controller.showSummaryPage.value
                      ? controller.summaryTitle
                      : controller.chapterTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textBlack,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (controller.subtitle.isNotEmpty)
                  Text(
                    controller.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.orange,
              ),
              onPressed: () async {
                if (await _confirmExit(context)) {
                  Get.back();
                }
              },
            ),
            actions: [
              if (!controller.isFiksi)
                Obx(
                  () => IconButton(
                    onPressed: controller.toggleRak,
                    icon: Icon(
                      controller.inRak.value
                          ? Icons.library_books_rounded
                          : Icons.library_add_rounded,
                      color: controller.inRak.value
                          ? AppColors.yellow
                          : AppColors.orange,
                    ),
                    tooltip: 'Rak Buku',
                  ),
                ),
              if (controller.hasChapters)
                Builder(
                  builder: (scaffoldContext) => IconButton(
                    onPressed: () =>
                        Scaffold.of(scaffoldContext).openEndDrawer(),
                    icon: const Icon(
                      Icons.menu_open_rounded,
                      color: AppColors.orange,
                    ),
                    tooltip: 'Daftar bab',
                  ),
                ),
              Obx(
                  () => IconButton(
                    onPressed: controller.toggleVoice,
                    icon: Icon(
                      Icons.volume_up_rounded,
                      color: controller.voiceEnabled.value
                          ? AppColors.orange
                          : Colors.grey,
                    ),
                    tooltip: 'Suara aktif otomatis',
                  ),
                ),
              const SizedBox(width: 6),
            ],
          ),
          endDrawer: controller.hasChapters
              ? Drawer(
                  child: SafeArea(
                    child: _buildChapterNavigator(compact: false),
                  ),
                )
              : null,
          body: SafeArea(
            child: Stack(
              children: [
                _buildBackground(),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 980;
                    return Row(
                      children: [
                        Expanded(child: _buildContent(isWide: isWide)),
                        if (isWide && controller.hasChapters)
                          SizedBox(
                            width: 320,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                0,
                                16,
                                20,
                                24,
                              ),
                              child: _buildChapterNavigator(compact: true),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFF3E0),
                  Color(0xFFE3F2FD),
                  Color(0xFFE8F5E9),
                  Color(0xFFFFFDE7),
                ],
              ),
            ),
          ),
          Positioned(
            top: -70,
            left: -50,
            child: _softBlob(size: 210, color: const Color(0xFFFFD180)),
          ),
          Positioned(
            top: 140,
            right: -60,
            child: _softBlob(size: 190, color: const Color(0xFF81D4FA)),
          ),
          Positioned(
            bottom: -60,
            left: -30,
            child: _softBlob(size: 220, color: const Color(0xFFA5D6A7)),
          ),
          Positioned(bottom: 80, right: 20, child: _dotGrid()),
        ],
      ),
    );
  }

  Widget _softBlob({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.6),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
    );
  }

  Widget _dotGrid() {
    return SizedBox(
      width: 90,
      height: 60,
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: List.generate(
          30,
          (index) => Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xFFFFAB91).withOpacity(0.7),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmExit(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi keluar'),
          content: Text(
            controller.isFiksi
                ? 'Yakin ingin keluar dari buku fiksi ini?'
                : 'Yakin ingin keluar dari materi ini?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Widget _buildContent({required bool isWide}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, isWide ? 12 : 20, 24),
      child: _buildMaterialSection(),
    );
  }

  Widget _buildMaterialSection() {
    return Obx(() {
      if (!controller.isLastPageLoaded.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.orange),
        );
      }

      if (controller.showSummaryPage.value) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReaderCard(_buildSummaryPage()),
              const SizedBox(height: 12),
              _buildProgressBar(),
              const SizedBox(height: 12),
              _buildCompletionActions(),
            ],
          ),
        );
      }

      final hasPdf = controller.pdfUrl != null && controller.pdfUrl!.isNotEmpty;
      if (!hasPdf) {
        return _buildTextSlides();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 6, child: _buildReaderCard(_buildPdfViewer())),
          const SizedBox(height: 12),
          Flexible(
            flex: 4,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReadAloudActions(),
                  const SizedBox(height: 12),
                  _buildSummaryEntryCta(),
                  const SizedBox(height: 12),
                  _buildProgressBar(),
                  const SizedBox(height: 12),
                  _buildCompletionActions(),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildPdfViewer() {
    return _LargePdfViewer(
      pdfUrl: controller.pdfUrl!,
      initialPage: controller.readerStartPage,
      onControlsReady: controller.registerPdfPageControls,
      onControlsDisposed: controller.clearPdfPageControls,
      onPageChanged: (current, total) {
        controller.updateTotalPages(total);
        controller.onPdfPageChanged(current);
      },
    );
  }

  Widget _buildReaderCard(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB74D), Color(0xFF4FC3F7), Color(0xFF81C784)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(borderRadius: BorderRadius.circular(16), child: child),
      ),
    );
  }

  Widget _buildTextSlides() {
    final textStyle = TextStyle(
      fontSize: controller.isFiksi ? 20 : 15,
      height: controller.isFiksi ? 1.55 : 1.6,
      color: AppColors.textBlack,
      fontFamily: 'Roboto',
      fontWeight: controller.isFiksi ? FontWeight.w500 : FontWeight.normal,
    );
    final pagePadding = EdgeInsets.all(controller.isFiksi ? 24 : 18);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (controller.isFiksi) ...[
          _buildFiksiHeader(),
          const SizedBox(height: 12),
        ],
        Expanded(
          child: _buildReaderCard(
            LayoutBuilder(
              builder: (context, constraints) {
                final pageInset = controller.isFiksi ? 48.0 : 36.0;
                final innerWidth = constraints.maxWidth - pageInset;
                final innerHeight = constraints.maxHeight - pageInset;
                final freezePages =
                    controller.quizCtaUnlocked.value &&
                    controller.textPages.isNotEmpty;
                final pages = freezePages
                    ? controller.textPages.toList()
                    : _paginateText(
                        controller.body,
                        textStyle,
                        innerWidth,
                        innerHeight,
                      );
                if (!freezePages) {
                  controller.updateTotalPages(pages.length);
                  controller.setTextPages(pages);
                }

                return PageFlipWidget(
                  key: ValueKey(
                    'text_flip_${pages.length}_${controller.readerStartPage}',
                  ),
                  controller: controller.textFlipController,
                  backgroundColor: Colors.white,
                  initialIndex: (controller.readerStartPage - 1).clamp(
                    0,
                    pages.length - 1,
                  ),
                  onPageFlipped: (pageIndex) {
                    controller.onTextPageChanged(pageIndex + 1, pages.length);
                  },
                  children: pages
                      .map(
                        (text) => Container(
                          color: Colors.white,
                          padding: pagePadding,
                          alignment: Alignment.topLeft,
                          child: Text(text, style: textStyle),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReadAloudActions(),
                const SizedBox(height: 12),
                _buildSummaryEntryCta(),
                const SizedBox(height: 12),
                _buildProgressBar(),
                const SizedBox(height: 12),
                _buildCompletionActions(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFiksiHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              controller.coverImage,
              width: 72,
              height: 96,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 72,
                height: 96,
                color: AppColors.yellow.withValues(alpha: 0.28),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  color: AppColors.orange,
                  size: 34,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.category.isNotEmpty
                      ? controller.category
                      : 'Buku Fiksi',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.orange,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  controller.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textBlack,
                    height: 1.2,
                    fontFamily: 'Roboto',
                  ),
                ),
                if (controller.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    controller.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[700],
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<String> _paginateText(
    String text,
    TextStyle style,
    double maxWidth,
    double maxHeight,
  ) {
    final cleaned = text
        .replaceAll('\r\n', '\n')
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p\s*>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .replaceAll(RegExp(r' *\n *'), '\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
    if (cleaned.isEmpty) return [''];

    final paragraphs = cleaned.split(RegExp(r'\n\s*\n'));
    final pages = <String>[];
    var current = '';

    bool fits(String candidate) {
      final painter = TextPainter(
        text: TextSpan(text: candidate, style: style),
        textDirection: TextDirection.ltr,
      );
      painter.layout(maxWidth: maxWidth);
      return painter.height <= maxHeight;
    }

    void pushCurrent() {
      if (current.trim().isEmpty) return;
      pages.add(current.trimRight());
      current = '';
    }

    for (var pIndex = 0; pIndex < paragraphs.length; pIndex++) {
      final paragraph = paragraphs[pIndex].trim();
      if (paragraph.isEmpty) continue;
      final words = paragraph.split(RegExp(r'\s+'));

      for (var i = 0; i < words.length; i++) {
        final word = words[i];
        final next = current.isEmpty ? word : '$current $word';
        if (fits(next)) {
          current = next;
        } else {
          pushCurrent();
          current = word;
        }
      }

      // add paragraph break if not last paragraph
      if (pIndex < paragraphs.length - 1) {
        final next = current.isEmpty ? '\n\n' : '$current\n\n';
        if (fits(next)) {
          current = next;
        } else {
          pushCurrent();
        }
      }
    }

    pushCurrent();
    if (pages.isEmpty) {
      pages.add(cleaned);
    }
    return pages;
  }

  Widget _buildProgressBar() {
    return Obx(() {
      final total = controller.totalPages;
      final current = controller.lastSessionPage.value;
      final percent = total <= 0 ? 0 : ((current / total) * 100).round();
      final progress = total <= 0 ? 0.0 : (current / total).clamp(0.0, 1.0);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag_rounded, color: AppColors.orange, size: 16),
              const SizedBox(width: 6),
              const Text(
                'Progress',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textBlack,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.orange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$percent%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Container(color: Colors.grey[200]),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFFF8A65),
                            Color(0xFFFFD54F),
                            Color(0xFF81D4FA),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildReadAloudActions() {
    return Obx(() {
      final isBusy = controller.isProcessingOcr.value;
      final isReading = controller.isReadingPage.value;
      final hasPdf = controller.pdfUrl != null && controller.pdfUrl!.isNotEmpty;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.record_voice_over_rounded,
                  color: AppColors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hasPdf
                        ? 'Bacakan halaman ${controller.lastSessionPage.value}'
                        : 'Bacakan materi teks',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textBlack,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              hasPdf
                  ? 'Aplikasi akan merender halaman PDF, menjalankan OCR, lalu membacakannya.'
                  : 'Aplikasi akan membacakan halaman teks yang sedang terbuka.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: hasPdf
                          ? (isBusy ? null : controller.readCurrentPageAloud)
                          : controller.readCurrentPageAloud,
                      icon: isBusy
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.play_arrow_rounded),
                      label: Text(
                        isBusy
                            ? 'Memproses...'
                            : hasPdf
                            ? 'Bacakan Halaman'
                            : 'Bacakan Teks',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: isReading ? controller.stopReadingPage : null,
                    icon: const Icon(Icons.stop_rounded),
                    label: const Text('Stop'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.orange,
                      side: const BorderSide(color: AppColors.orange),
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
      );
    });
  }

  Widget _buildCompletionActions() {
    return Obx(() {
      final showQuiz = controller.showQuizCta.value || controller.hasChapterQuiz;
      final showNextChapter = controller.hasNextChapter;
      final onSummaryPage = controller.showSummaryPage.value;
      if ((!showQuiz && !showNextChapter) || !onSummaryPage) {
        return const SizedBox.shrink();
      }
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              showNextChapter
                  ? 'Bab ini selesai dibaca.'
                  : 'Kamu sudah sampai di akhir bab.',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textBlack,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              showQuiz
                  ? 'Lanjutkan ke kuis jika tersedia, atau pilih bab lain dari daftar isi.'
                  : 'Lanjutkan ke bab berikutnya untuk meneruskan materi.',
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
            if (showNextChapter) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: controller.openNextChapter,
                  icon: const Icon(Icons.menu_book_rounded),
                  label: const Text('Lanjut ke Bab Berikutnya'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
            if (showQuiz) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: controller.goToQuizIntro,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.quiz_rounded),
                      const SizedBox(width: 8),
                      Text(
                        controller.hasChapterQuiz
                            ? 'Kerjakan Kuis Bab'
                            : 'Lanjut ke Kuis Materi',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildSummaryCard() {
    return Obx(() {
      final hasSummary = controller.hasChapterSummary;
      final canGenerate = controller.canGenerateSummary;
      final isBusy = controller.isGeneratingSummary.value;
      if (!hasSummary && !canGenerate) {
        return const SizedBox.shrink();
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFF3E0), Color(0xFFFFF8EF), Color(0xFFE8F4FF)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.orange,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ringkas dan Mudah Diingat',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.orange,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          controller.summaryTitle,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textBlack,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (hasSummary) ...[
              if (controller.summaryShort.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    controller.summaryShort,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              if (controller.summaryKeyPoints.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Inti Bab Ini',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textBlack,
                  ),
                ),
                const SizedBox(height: 10),
                ...List.generate(controller.summaryKeyPoints.length, (index) {
                  final point = controller.summaryKeyPoints[index];
                  final pointStyle = _summaryPointStyle(point, index);
                  final accent = pointStyle.$1;
                  final icon = pointStyle.$2;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: accent.withOpacity(0.30)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: accent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              icon,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              point,
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1.45,
                                color: AppColors.textBlack,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
              if (controller.summaryMemoryTip.isNotEmpty) ...[
                const SizedBox(height: 8),
                _summaryInfoBox(
                  title: 'Tips mengingat',
                  body: controller.summaryMemoryTip,
                  backgroundColor: const Color(0xFFFFF3E0),
                  icon: Icons.psychology_alt_rounded,
                ),
              ],
              if (controller.summaryExample.isNotEmpty) ...[
                const SizedBox(height: 8),
                _summaryInfoBox(
                  title: 'Contoh sederhana',
                  body: controller.summaryExample,
                  backgroundColor: const Color(0xFFE8F5E9),
                  icon: Icons.lightbulb_rounded,
                ),
              ],
              if (controller.summaryKeywords.isNotEmpty) ...[
                const SizedBox(height: 10),
                const Text(
                  'Kata Kunci',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textBlack,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.summaryKeywords
                      .map(
                        (keyword) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.orange.withOpacity(0.14),
                                AppColors.yellow.withOpacity(0.22),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            keyword,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.orange,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Text(
                  'Rangkuman AI untuk bab ini belum tersedia. Kamu bisa membuatnya dulu sebelum lanjut ke kuis.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
            if (canGenerate) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: OutlinedButton.icon(
                  onPressed: isBusy ? null : controller.generateChapterSummary,
                  icon: isBusy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome_rounded),
                  label: Text(
                    isBusy
                        ? 'Membuat rangkuman...'
                        : hasSummary
                        ? 'Perbarui Rangkuman'
                        : 'Generate Rangkuman',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.orange,
                    side: const BorderSide(color: AppColors.orange),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildSummaryEntryCta() {
    return Obx(() {
      final isAtEnd =
          controller.totalPages > 0 &&
          controller.lastSessionPage.value == controller.totalPages;
      final shouldShow =
          controller.hasSummaryFlow && isAtEnd && !controller.showSummaryPage.value;
      if (!shouldShow) return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Isi bab sudah selesai.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textBlack,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              controller.hasChapterSummary
                  ? 'Lanjut ke halaman rangkuman untuk melihat inti bab ini.'
                  : 'Buka halaman rangkuman untuk membuat dan melihat ringkasan bab ini.',
              style: TextStyle(
                fontSize: 12,
                height: 1.45,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton.icon(
                onPressed: () => controller.showSummaryPage.value = true,
                icon: const Icon(Icons.auto_awesome_rounded),
                label: const Text('Buka Halaman Rangkuman'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSummaryPage() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFFF3E0),
                    Color(0xFFFFF8EF),
                    Color(0xFFE8F4FF),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -8,
                    top: -6,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD54F).withOpacity(0.20),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 30,
                    bottom: -10,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF81D4FA).withOpacity(0.22),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.96),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: AppColors.orange,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Halaman Rangkuman',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.orange,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              controller.summaryTitle,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textBlack,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Yuk lihat inti pelajaran ini dengan cara yang lebih mudah dipahami.',
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.35,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: () => controller.showSummaryPage.value = false,
                icon: const Icon(Icons.menu_book_rounded),
                label: const Text('Kembali ke Bacaan'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.orange,
                  side: const BorderSide(color: AppColors.orange),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            _buildSummaryCard(),
          ],
        ),
      ),
    );
  }

  Widget _summaryInfoBox({
    required String title,
    required String body,
    required Color backgroundColor,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.orange),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textBlack,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(
              fontSize: 12,
              height: 1.45,
              color: AppColors.textBlack,
            ),
          ),
        ],
      ),
    );
  }

  (Color, IconData) _summaryPointStyle(String point, int index) {
    final text = point.toLowerCase();

    if (text.contains('ingat') ||
        text.contains('menghafal') ||
        text.contains('memori')) {
      return (const Color(0xFFFFB74D), Icons.psychology_alt_rounded);
    }

    if (text.contains('contoh') || text.contains('misalnya')) {
      return (const Color(0xFF4FC3F7), Icons.lightbulb_rounded);
    }

    if (text.contains('budaya') ||
        text.contains('tradisi') ||
        text.contains('adat')) {
      return (const Color(0xFFFF8A65), Icons.celebration_rounded);
    }

    if (text.contains('hewan') ||
        text.contains('kancil') ||
        text.contains('hutan')) {
      return (const Color(0xFF81C784), Icons.pets_rounded);
    }

    if (text.contains('baik') ||
        text.contains('tolong') ||
        text.contains('peduli') ||
        text.contains('teman')) {
      return (const Color(0xFFE57373), Icons.favorite_rounded);
    }

    if (text.contains('aturan') ||
        text.contains('harus') ||
        text.contains('jangan') ||
        text.contains('langkah')) {
      return (const Color(0xFF9575CD), Icons.rule_rounded);
    }

    final accents = <Color>[
      const Color(0xFFFF8A65),
      const Color(0xFF4FC3F7),
      const Color(0xFF81C784),
      const Color(0xFFFFD54F),
    ];
    final icons = <IconData>[
      Icons.star_rounded,
      Icons.lightbulb_rounded,
      Icons.favorite_rounded,
      Icons.flag_rounded,
    ];
    return (accents[index % accents.length], icons[index % icons.length]);
  }

  Widget _buildChapterNavigator({required bool compact}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(compact ? 22 : 0),
        boxShadow: compact
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daftar Bab',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textBlack,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  controller.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: controller.chapterList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final chapter = controller.chapterList[index];
                final selected = index == controller.currentChapterIndex;
                final chapterTitle =
                    chapter['judul_bab']?.toString() ??
                    chapter['judul']?.toString() ??
                    'Bab ${index + 1}';
                final hasQuiz =
                    chapter['kuis'] != null ||
                    chapter['kuis_id'] != null ||
                    chapter['quiz_id'] != null ||
                    (chapter['kuis_list'] is List &&
                        (chapter['kuis_list'] as List).isNotEmpty);

                return InkWell(
                  onTap: () async {
                    if (!compact) {
                      Navigator.of(context).maybePop();
                    }
                    await controller.openChapterAt(index);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.orange.withOpacity(0.10)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected
                            ? AppColors.orange
                            : const Color(0xFFE5E7EB),
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: selected ? AppColors.orange : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: selected ? Colors.white : AppColors.orange,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chapterTitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textBlack,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                hasQuiz ? 'Ada kuis' : 'Bab bacaan',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LargePdfViewer extends StatefulWidget {
  const _LargePdfViewer({
    required this.pdfUrl,
    required this.initialPage,
    required this.onControlsReady,
    required this.onControlsDisposed,
    required this.onPageChanged,
  });

  final String pdfUrl;
  final int initialPage;
  final void Function({
    required Future<void> Function() nextPage,
    required Future<void> Function() previousPage,
  })
  onControlsReady;
  final VoidCallback onControlsDisposed;
  final void Function(int currentPage, int totalPages) onPageChanged;

  @override
  State<_LargePdfViewer> createState() => _LargePdfViewerState();
}

class _LargePdfViewerState extends State<_LargePdfViewer> {
  PdfController? _pdfController;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  @override
  void didUpdateWidget(covariant _LargePdfViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pdfUrl != widget.pdfUrl ||
        oldWidget.initialPage != widget.initialPage) {
      _pdfController?.dispose();
      _pdfController = null;
      _loadPdf();
    }
  }

  void _loadPdf() {
    _pdfController = PdfController(
      document: _openNetworkPdf(widget.pdfUrl),
      initialPage: widget.initialPage < 1 ? 1 : widget.initialPage,
      viewportFraction: 1,
    );
    widget.onControlsReady(
      nextPage: _goToNextPage,
      previousPage: _goToPreviousPage,
    );
  }

  Future<PdfDocument> _openNetworkPdf(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Gagal memuat file materi (${response.statusCode})');
    }
    return PdfDocument.openData(response.bodyBytes);
  }

  Future<void> _goToNextPage() async {
    final controller = _pdfController;
    final totalPages = controller?.pagesCount;
    if (controller == null || totalPages == null) return;
    if (controller.page >= totalPages) return;

    await controller.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _goToPreviousPage() async {
    final controller = _pdfController;
    if (controller == null || controller.pagesCount == null) return;
    if (controller.page <= 1) return;

    await controller.previousPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    widget.onControlsDisposed();
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _pdfController;
    if (controller == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.orange),
      );
    }

    return PdfView(
      controller: controller,
      scrollDirection: Axis.horizontal,
      pageSnapping: true,
      backgroundDecoration: const BoxDecoration(color: Colors.white),
      onDocumentLoaded: (document) {
        widget.onPageChanged(controller.page, document.pagesCount);
      },
      onPageChanged: (page) {
        widget.onPageChanged(page, controller.pagesCount ?? 1);
      },
      builders: PdfViewBuilders<DefaultBuilderOptions>(
        options: const DefaultBuilderOptions(),
        documentLoaderBuilder: (_) => const Center(
          child: CircularProgressIndicator(color: AppColors.orange),
        ),
        pageLoaderBuilder: (_) => const Center(
          child: CircularProgressIndicator(color: AppColors.orange),
        ),
        errorBuilder: (_, error) => Center(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textBlack,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
