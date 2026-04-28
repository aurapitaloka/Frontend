import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';

class PdfPageOcrService {
  PdfPageOcrService._();

  static final PdfPageOcrService instance = PdfPageOcrService._();

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

      final targetWidth = page.width >= 3200
          ? 3200.0
          : page.width < 2400
          ? 2400.0
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

      final extractedSections = <String>[
        await _extractTextFromImageFile(fullPageFile),
      ];

      final decodedImage = img.decodeImage(rendered.bytes);
      if (decodedImage != null) {
        final cropRanges = <_OcrCropRegion>[
          const _OcrCropRegion(
            startYFactor: 0.00,
            endYFactor: 0.45,
            startXFactor: 0.00,
            endXFactor: 1.00,
            scale: 1.35,
          ),
          const _OcrCropRegion(
            startYFactor: 0.32,
            endYFactor: 0.78,
            startXFactor: 0.00,
            endXFactor: 1.00,
            scale: 1.45,
          ),
          const _OcrCropRegion(
            startYFactor: 0.55,
            endYFactor: 1.00,
            startXFactor: 0.00,
            endXFactor: 1.00,
            scale: 1.6,
          ),
          const _OcrCropRegion(
            startYFactor: 0.48,
            endYFactor: 0.92,
            startXFactor: 0.10,
            endXFactor: 0.90,
            scale: 2.0,
            highContrast: true,
          ),
          const _OcrCropRegion(
            startYFactor: 0.62,
            endYFactor: 0.96,
            startXFactor: 0.12,
            endXFactor: 0.88,
            scale: 2.35,
            highContrast: true,
          ),
        ];

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
          extractedSections.add(await _extractTextFromImageFile(cropFile));
        }
      }

      return _mergeExtractedText(extractedSections);
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

  Future<String> _extractTextFromImageFile(File imageFile) async {
    final inputImage = InputImage.fromFilePath(imageFile.path);
    final result = await _recognizer.processImage(inputImage);
    return _buildTextFromRecognized(result);
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

  String _mergeExtractedText(List<String> sections) {
    final mergedLines = <String>[];
    final seen = <String>{};

    for (final section in sections) {
      for (final rawLine in section.split('\n')) {
        final line = rawLine.trim();
        if (line.isEmpty) continue;

        final normalized = line
            .toLowerCase()
            .replaceAll(RegExp(r'\s+'), ' ')
            .replaceAll(RegExp(r'[^a-z0-9 ]'), '');

        if (normalized.isEmpty || seen.contains(normalized)) {
          continue;
        }

        seen.add(normalized);
        mergedLines.add(line);
      }
    }

    return mergedLines.join('\n').trim();
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
