import 'package:flutter_tts/flutter_tts.dart';
import 'aac_tts_service.dart';

class _FlutterAacTtsService implements AacTtsService {
  final FlutterTts _tts = FlutterTts();

  _FlutterAacTtsService() {
    _tts.setLanguage('id-ID');
    _tts.setSpeechRate(0.5);
    _tts.setPitch(1.0);
  }

  @override
  Future<void> speak(String text) async {
    final cleaned = text.trim();
    if (cleaned.isEmpty) return;
    await _tts.stop();
    await _tts.speak(cleaned);
  }

  @override
  Future<void> stop() async {
    await _tts.stop();
  }
}

AacTtsService createAacTtsServiceImpl() => _FlutterAacTtsService();
