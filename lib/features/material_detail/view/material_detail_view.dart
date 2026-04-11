import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:page_flip/page_flip.dart';
import 'package:flutter_pdf_flipbook/flutter_pdf_flipbook.dart';
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
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.grey[50],
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.orange),
              onPressed: () async {
                if (await _confirmExit(context)) {
                  Get.back();
                }
              },
            ),
            actions: [
              Obx(
                () => IconButton(
                  onPressed: controller.toggleRak,
                  icon: Icon(
                    controller.inRak.value ? Icons.library_books_rounded : Icons.library_add_rounded,
                    color: controller.inRak.value ? AppColors.yellow : AppColors.orange,
                  ),
                  tooltip: 'Rak Buku',
                ),
              ),
              Obx(
                () => IconButton(
                  onPressed: controller.toggleVoice,
                  icon: Icon(
                    Icons.volume_up_rounded,
                    color: controller.voiceEnabled.value ? AppColors.orange : Colors.grey,
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
                Column(
                  children: [
                    Expanded(child: _buildContent()),
                  ],
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
                  Color(0xFFFFF8E1),
                  Color(0xFFFFFDE7),
                  Color(0xFFFDF8E4),
                ],
              ),
            ),
          ),
          Positioned(
            top: -60,
            left: -40,
            child: _softBlob(
              size: 180,
              color: const Color(0xFFFFE0B2),
            ),
          ),
          Positioned(
            top: 120,
            right: -50,
            child: _softBlob(
              size: 160,
              color: const Color(0xFFFFCC80),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -20,
            child: _softBlob(
              size: 200,
              color: const Color(0xFFFFF3E0),
            ),
          ),
          Positioned(
            bottom: 80,
            right: 20,
            child: _dotGrid(),
          ),
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
              color: const Color(0xFFFFCC80).withOpacity(0.6),
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
          content: const Text('Yakin ingin keluar dari materi ini?'),
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
    final hasPdf = controller.pdfUrl != null && controller.pdfUrl!.isNotEmpty;
    if (!hasPdf) {
      return _buildTextSlides();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: PdfBookViewer(
                pdfUrl: controller.pdfUrl!,
                backgroundColor: Colors.white,
                showNavigationControls: false,
                onPageChanged: (current, total) {
                  controller.updateTotalPages(total);
                  controller.onPdfPageChanged(current);
                },
                onError: (_) {},
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildProgressBar(),
      ],
    );
  }

  Widget _buildTextSlides() {
    const textStyle = TextStyle(
      fontSize: 15,
      height: 1.6,
      color: AppColors.textBlack,
      fontFamily: 'Roboto',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final innerWidth = constraints.maxWidth - 36;
                final innerHeight = constraints.maxHeight - 36;
                final pages = _paginateText(
                  controller.body,
                  textStyle,
                  innerWidth,
                  innerHeight,
                );
                controller.updateTotalPages(pages.length);

                return ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: PageFlipWidget(
                    key: ValueKey(
                      'text_flip_${pages.length}_${controller.lastSessionPage.value}',
                    ),
                    controller: controller.textFlipController,
                    backgroundColor: Colors.white,
                    initialIndex:
                        (controller.lastSessionPage.value - 1).clamp(0, pages.length - 1),
                    onPageFlipped: (pageIndex) {
                      controller.onTextPageChanged(pageIndex + 1, pages.length);
                    },
                    children: pages
                        .map(
                          (text) => Container(
                            color: Colors.white,
                            padding: const EdgeInsets.all(18),
                            alignment: Alignment.topLeft,
                            child: Text(
                              text,
                              style: textStyle,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildProgressBar(),
      ],
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
              const Text(
                'Progress',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textBlack,
                ),
              ),
              const Spacer(),
              Text(
                '$percent%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.orange),
            ),
          ),
        ],
      );
    });
  }

}
