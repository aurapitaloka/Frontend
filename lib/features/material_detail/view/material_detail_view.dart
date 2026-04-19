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
            backgroundColor: Colors.transparent,
            elevation: 0,
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
              Obx(
                () => IconButton(
                  onPressed: controller.toggleVoice,
                  icon: Icon(
                    Icons.volume_up_rounded,
                    color: controller.voiceEnabled.value
                        ? AppColors.orange
                        : Colors.grey,
                  ),
                  tooltip: 'Suara',
                ),
              ),
              const SizedBox(width: 6),
            ],
          ),
          body: SafeArea(
            child: Stack(
              children: [
                _buildBackground(),
                Column(children: [Expanded(child: _buildContent())]),
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

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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

      final hasPdf = controller.pdfUrl != null && controller.pdfUrl!.isNotEmpty;
      if (!hasPdf) {
        return _buildTextSlides();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildReaderCard(_buildPdfViewer())),
          const SizedBox(height: 12),
          _buildProgressBar(),
          const SizedBox(height: 12),
          _buildQuizCta(),
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
                final pages = _paginateText(
                  controller.body,
                  textStyle,
                  innerWidth,
                  innerHeight,
                );
                controller.updateTotalPages(pages.length);

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
        _buildProgressBar(),
        const SizedBox(height: 12),
        _buildQuizCta(),
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
    final cleaned = text.replaceAll('\r\n', '\n').trim();
    if (cleaned.isEmpty) return [''];

    final paragraphs = cleaned.split('\n\n');
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

  Widget _buildQuizCta() {
    return Obx(() {
      if (!controller.showQuizCta.value) return const SizedBox.shrink();
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
              'Kamu sudah selesai materi ini!',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textBlack,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Yuk lanjut uji pemahamanmu di kuis.',
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: controller.goToQuizIntro,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Lanjut ke Kuis'),
              ),
            ),
          ],
        ),
      );
    });
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
