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

  Future<void> stop() async {
    await _tts.stop();
    _completeSpeakIfNeeded();
  }

  void _completeSpeakIfNeeded() {
    final completer = _speakCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
    _speakCompleter = null;
  }
}
