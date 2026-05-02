import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';

class PdfPageOcrService {
  PdfPageOcrService._();

  static final PdfPageOcrService instance = PdfPageOcrService._();
  static const int _minimumUsefulTextLength = 220;
  static const int _minimumUsefulLineCount = 8;

  final TextRecognizer _recognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  Future<String> extractTextFromPdfPage({
    required Uint8List pdfBytes,
    required int pageNumber,
  }) async {
    final document = await PdfDocument.openData(pdfBytes);
    PdfPage? page;
    final tempFiles = <File>[];

    try {
      final safePage = pageNumber.clamp(1, document.pagesCount);
      page = await document.getPage(safePage);

      final targetWidth = page.width >= 2200
          ? 2200.0
          : page.width < 1600
          ? 1600.0
          : page.width;
      final ratio = targetWidth / page.width;
      final targetHeight = page.height * ratio;

      final rendered = await page.render(
        width: targetWidth,
        height: targetHeight,
        format: PdfPageImageFormat.png,
      );
      if (rendered == null || rendered.bytes.isEmpty) {
        return '';
      }

      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final fullPageFile = File(
        '${tempDir.path}${Platform.pathSeparator}ocr_page_${safePage}_${timestamp}_full.png',
      );
      await fullPageFile.writeAsBytes(rendered.bytes, flush: true);
      tempFiles.add(fullPageFile);

      final extractedLines = <_OcrLineCandidate>[
        ...await _extractLineCandidatesFromImageFile(
          fullPageFile,
          offsetX: 0,
          offsetY: 0,
          scale: 1,
        ),
      ];
      final fullPageText = _mergeExtractedText(extractedLines);
      if (_isUsefulExtraction(fullPageText, extractedLines)) {
        return fullPageText;
      }

      final decodedImage = img.decodeImage(rendered.bytes);
      if (decodedImage != null) {
        final cropRanges = _buildCropRegions();

        for (var index = 0; index < cropRanges.length; index++) {
          final range = cropRanges[index];
          final startY =
              (decodedImage.height * range.startYFactor).round().clamp(
            0,
            decodedImage.height - 1,
          );
          final endY = (decodedImage.height * range.endYFactor).round().clamp(
            startY + 1,
            decodedImage.height,
          );
          final startX =
              (decodedImage.width * range.startXFactor).round().clamp(
            0,
            decodedImage.width - 1,
          );
          final endX = (decodedImage.width * range.endXFactor).round().clamp(
            startX + 1,
            decodedImage.width,
          );

          final cropped = img.copyCrop(
            decodedImage,
            x: startX,
            y: startY,
            width: endX - startX,
            height: endY - startY,
          );

          final prepared = _prepareImageForOcr(
            cropped,
            scale: range.scale,
            highContrast: range.highContrast,
          );

          final cropFile = File(
            '${tempDir.path}${Platform.pathSeparator}ocr_page_${safePage}_${timestamp}_slice_$index.png',
          );
          await cropFile.writeAsBytes(img.encodePng(prepared), flush: true);
          tempFiles.add(cropFile);
          extractedLines.addAll(
            await _extractLineCandidatesFromImageFile(
              cropFile,
              offsetX: startX.toDouble(),
              offsetY: startY.toDouble(),
              scale: range.scale,
            ),
          );
        }
      }

      return _mergeExtractedText(extractedLines);
    } finally {
      if (page != null && !page.isClosed) {
        await page.close();
      }
      if (!document.isClosed) {
        await document.close();
      }
      for (final file in tempFiles) {
        if (await file.exists()) {
          await file.delete();
        }
      }
    }
  }

  Future<List<_OcrLineCandidate>> _extractLineCandidatesFromImageFile(
    File imageFile, {
    required double offsetX,
    required double offsetY,
    required double scale,
  }) async {
    final inputImage = InputImage.fromFilePath(imageFile.path);
    final result = await _recognizer.processImage(inputImage);
    return _buildLineCandidates(
      result,
      offsetX: offsetX,
      offsetY: offsetY,
      scale: scale,
    );
  }

  img.Image _prepareImageForOcr(
    img.Image source, {
    required double scale,
    bool highContrast = false,
  }) {
    final resized = img.copyResize(
      source,
      width: (source.width * scale).round(),
    );

    if (!highContrast) {
      return resized;
    }

    final grayscale = img.grayscale(resized);
    return img.adjustColor(
      grayscale,
      contrast: 1.35,
      saturation: 0,
      brightness: 0.05,
    );
  }

  String _buildTextFromRecognized(RecognizedText result) {
    final orderedBlocks = [...result.blocks]
      ..sort((a, b) {
        final topCompare = a.boundingBox.top.compareTo(b.boundingBox.top);
        if (topCompare != 0) return topCompare;
        return a.boundingBox.left.compareTo(b.boundingBox.left);
      });

    final lines = <String>[];
    for (final block in orderedBlocks) {
      final orderedLines = [...block.lines]
        ..sort((a, b) {
          final topCompare = a.boundingBox.top.compareTo(b.boundingBox.top);
          if (topCompare != 0) return topCompare;
          return a.boundingBox.left.compareTo(b.boundingBox.left);
        });

      for (final line in orderedLines) {
        final text = line.text.trim();
        if (text.isNotEmpty) {
          lines.add(text);
        }
      }
    }

    if (lines.isEmpty) {
      return result.text.trim();
    }

    return lines.join('\n').trim();
  }

  List<_OcrCropRegion> _buildCropRegions() {
    return const <_OcrCropRegion>[
      _OcrCropRegion(
        startYFactor: 0.18,
        endYFactor: 0.86,
        startXFactor: 0.10,
        endXFactor: 0.90,
        scale: 1.35,
      ),
      _OcrCropRegion(
        startYFactor: 0.42,
        endYFactor: 0.84,
        startXFactor: 0.10,
        endXFactor: 0.90,
        scale: 1.75,
      ),
      _OcrCropRegion(
        startYFactor: 0.52,
        endYFactor: 0.90,
        startXFactor: 0.14,
        endXFactor: 0.86,
        scale: 2.0,
        highContrast: true,
      ),
    ];
  }

  bool _isUsefulExtraction(String text, List<_OcrLineCandidate> lines) {
    final normalized = text.trim();
    if (normalized.isEmpty) return false;

    final uniqueLongLines = lines
        .map((item) => item.text.trim())
        .where((item) => item.length >= 18)
        .toSet()
        .length;

    if (normalized.length >= _minimumUsefulTextLength &&
        uniqueLongLines >= _minimumUsefulLineCount) {
      return true;
    }

    return normalized.length >= 320 && uniqueLongLines >= 5;
  }

  List<_OcrLineCandidate> _buildLineCandidates(
    RecognizedText result, {
    required double offsetX,
    required double offsetY,
    required double scale,
  }) {
    final candidates = <_OcrLineCandidate>[];
    final orderedBlocks = [...result.blocks]
      ..sort((a, b) {
        final topCompare = a.boundingBox.top.compareTo(b.boundingBox.top);
        if (topCompare != 0) return topCompare;
        return a.boundingBox.left.compareTo(b.boundingBox.left);
      });

    for (final block in orderedBlocks) {
      final orderedLines = [...block.lines]
        ..sort((a, b) {
          final topCompare = a.boundingBox.top.compareTo(b.boundingBox.top);
          if (topCompare != 0) return topCompare;
          return a.boundingBox.left.compareTo(b.boundingBox.left);
        });

      for (final line in orderedLines) {
        final text = _normalizeRecognizedLine(line.text);
        if (text.isEmpty) continue;

        final box = line.boundingBox;
        candidates.add(
          _OcrLineCandidate(
            text: text,
            normalized: _normalizeForCompare(text),
            top: offsetY + (box.top / scale),
            left: offsetX + (box.left / scale),
            bottom: offsetY + (box.bottom / scale),
            right: offsetX + (box.right / scale),
          ),
        );
      }
    }

    if (candidates.isEmpty) {
      final fallbackText = _buildTextFromRecognized(result);
      if (fallbackText.isNotEmpty) {
        for (final rawLine in fallbackText.split('\n')) {
          final text = _normalizeRecognizedLine(rawLine);
          if (text.isEmpty) continue;
          candidates.add(
            _OcrLineCandidate(
              text: text,
              normalized: _normalizeForCompare(text),
              top: offsetY,
              left: offsetX,
              bottom: offsetY,
              right: offsetX,
            ),
          );
        }
      }
    }

    return candidates;
  }

  String _mergeExtractedText(List<_OcrLineCandidate> lines) {
    if (lines.isEmpty) return '';

    final sorted = [...lines]
      ..sort((a, b) {
        final topDiff = (a.top - b.top).abs();
        if (topDiff > 10) {
          return a.top.compareTo(b.top);
        }
        final leftDiff = (a.left - b.left).abs();
        if (leftDiff > 6) {
          return a.left.compareTo(b.left);
        }
        return b.area.compareTo(a.area);
      });

    final merged = <_OcrLineCandidate>[];
    for (final candidate in sorted) {
      if (candidate.normalized.isEmpty) continue;
      final duplicate = merged.any((existing) {
        if (existing.normalized != candidate.normalized) return false;
        final verticalClose = (existing.top - candidate.top).abs() < 22;
        final horizontalClose = (existing.left - candidate.left).abs() < 28;
        return verticalClose && horizontalClose;
      });
      if (!duplicate) {
        merged.add(candidate);
      }
    }

    merged.sort((a, b) {
      final topDiff = (a.top - b.top).abs();
      if (topDiff > 10) {
        return a.top.compareTo(b.top);
      }
      return a.left.compareTo(b.left);
    });

    final buffer = StringBuffer();
    _OcrLineCandidate? previous;

    for (final line in merged) {
      if (previous != null) {
        final verticalGap = line.top - previous.bottom;
        final isNewParagraph = verticalGap > 26;
        final sameRow = (line.top - previous.top).abs() < 10;
        if (sameRow) {
          buffer.write(' ');
        } else if (isNewParagraph) {
          buffer.write('\n\n');
        } else {
          buffer.write('\n');
        }
      }
      buffer.write(line.text);
      previous = line;
    }

    return buffer.toString().trim();
  }

  String _normalizeRecognizedLine(String text) {
    return text
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll('|', 'I')
        .trim();
  }

  String _normalizeForCompare(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[^a-z0-9 ]'), '')
        .trim();
  }

  Future<void> close() async {
    await _recognizer.close();
  }
}

class _OcrCropRegion {
  const _OcrCropRegion({
    required this.startYFactor,
    required this.endYFactor,
    required this.startXFactor,
    required this.endXFactor,
    required this.scale,
    this.highContrast = false,
  });

  final double startYFactor;
  final double endYFactor;
  final double startXFactor;
  final double endXFactor;
  final double scale;
  final bool highContrast;
}

class _OcrLineCandidate {
  const _OcrLineCandidate({
    required this.text,
    required this.normalized,
    required this.top,
    required this.left,
    required this.bottom,
    required this.right,
  });

  final String text;
  final String normalized;
  final double top;
  final double left;
  final double bottom;
  final double right;

  double get area => (right - left).abs() * (bottom - top).abs();
}
