import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';

class VoiceGuideService {
  VoiceGuideService._();

  static final VoiceGuideService instance = VoiceGuideService._();

  final FlutterTts _tts = FlutterTts();
  bool _configured = false;
  Completer<void>? _speakCompleter;

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    await _tts.setLanguage('id-ID');
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    await _tts.awaitSpeakCompletion(true);
    _tts.setCompletionHandler(() {
      _completeSpeakIfNeeded();
    });
    _tts.setCancelHandler(() {
      _completeSpeakIfNeeded();
    });
    _tts.setErrorHandler((_) {
      _completeSpeakIfNeeded();
    });
    _configured = true;
  }

  Future<void> speak(String text) async {
    await _ensureConfigured();
    await _tts.stop();
    _speakCompleter = Completer<void>();
    await _tts.speak(text);
    await _speakCompleter?.future;
  }

  Future<void> speakLongText(String text, {int maxChunkLength = 350}) async {
    final normalized = _normalizeText(text);
    if (normalized.isEmpty) return;

    final chunks = _chunkText(normalized, maxChunkLength: maxChunkLength);
    for (final chunk in chunks) {
      if (chunk.trim().isEmpty) continue;
      await speak(chunk);
    }
  }

  Future<void> stop() async {
    await _tts.stop();
    _completeSpeakIfNeeded();
  }

  String _normalizeText(String text) {
    return text
        .replaceAll('\r\n', '\n')
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  List<String> _chunkText(String text, {required int maxChunkLength}) {
    if (text.length <= maxChunkLength) return [text];

    final paragraphs = text
        .split(RegExp(r'\n\s*\n'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    if (paragraphs.isEmpty) return [text];

    final chunks = <String>[];
    var current = '';

    void pushCurrent() {
      if (current.trim().isEmpty) return;
      chunks.add(current.trim());
      current = '';
    }

    for (final paragraph in paragraphs) {
      if (paragraph.length > maxChunkLength) {
        pushCurrent();
        final sentences = paragraph
            .split(RegExp(r'(?<=[.!?])\s+'))
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty);
        for (final sentence in sentences) {
          if (sentence.length <= maxChunkLength) {
            final next = current.isEmpty ? sentence : '$current $sentence';
            if (next.length <= maxChunkLength) {
              current = next;
            } else {
              pushCurrent();
              current = sentence;
            }
            continue;
          }

          pushCurrent();
          for (var i = 0; i < sentence.length; i += maxChunkLength) {
            final end = (i + maxChunkLength).clamp(0, sentence.length);
            chunks.add(sentence.substring(i, end).trim());
          }
        }
        continue;
      }

      final next = current.isEmpty ? paragraph : '$current\n\n$paragraph';
      if (next.length <= maxChunkLength) {
        current = next;
      } else {
        pushCurrent();
        current = paragraph;
      }
    }

    pushCurrent();
    return chunks.isEmpty ? [text] : chunks;
  }

  void _completeSpeakIfNeeded() {
    final completer = _speakCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
    _speakCompleter = null;
  }
}
