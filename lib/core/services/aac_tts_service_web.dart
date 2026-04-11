import 'dart:html' as html;
import 'aac_tts_service.dart';

class _WebAacTtsService implements AacTtsService {
  @override
  Future<void> speak(String text) async {
    final cleaned = text.trim();
    if (cleaned.isEmpty) return;
    final synth = html.window.speechSynthesis;
    synth?.cancel();
    final utter = html.SpeechSynthesisUtterance(cleaned);
    utter.lang = 'id-ID';
    synth?.speak(utter);
  }

  @override
  Future<void> stop() async {
    html.window.speechSynthesis?.cancel();
  }
}

AacTtsService createAacTtsServiceImpl() => _WebAacTtsService();
