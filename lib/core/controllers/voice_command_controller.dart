import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';

typedef CommandAction = void Function();

class VoiceCommandController extends GetxController {
  final SpeechToText _speech = SpeechToText();
  final RxBool isListening = false.obs;
  final RxBool autoListen = false.obs;
  final RxString lastWords = ''.obs;
  final RxString error = ''.obs;

  final Map<String, CommandAction> _globalCommands = {};
  final List<Map<String, CommandAction>> _commandStack = [];

  void setGlobalCommands(Map<String, CommandAction> commands) {
    _globalCommands
      ..clear()
      ..addAll(commands);
  }

  void pushCommands(Map<String, CommandAction> commands) {
    _commandStack.add(commands);
  }

  void popCommands(Map<String, CommandAction> commands) {
    _commandStack.remove(commands);
  }

  Map<String, CommandAction> get _activeCommands {
    final merged = <String, CommandAction>{};
    merged.addAll(_globalCommands);
    for (final cmd in _commandStack) {
      merged.addAll(cmd);
    }
    return merged;
  }

  Future<void> toggleListening() async {
    if (isListening.value) {
      autoListen.value = false;
      await stopListening();
    } else {
      autoListen.value = true;
      await startListening();
    }
  }

  Future<void> enableContinuousListening() async {
    autoListen.value = true;
    await startListening();
  }

  Future<void> startListening() async {
    final mic = await Permission.microphone.request();
    if (!mic.isGranted) {
      error.value = 'Izin mikrofon ditolak.';
      return;
    }

    final available = await _speech.initialize(
      onError: (e) {
        error.value = e.errorMsg;
        isListening.value = false;
      },
      onStatus: (status) {
        if (status == 'notListening') {
          isListening.value = false;
          if (autoListen.value) {
            Future.delayed(const Duration(milliseconds: 400), () {
              if (autoListen.value && !isListening.value) {
                startListening();
              }
            });
          }
        }
      },
    );
    if (!available) {
      error.value = 'Speech recognition tidak tersedia.';
      return;
    }

    isListening.value = true;
    _speech.listen(
      localeId: 'id-ID',
      listenFor: const Duration(minutes: 5),
      pauseFor: const Duration(seconds: 2),
      partialResults: false,
      onResult: (result) {
        if (result.finalResult) {
          final text = result.recognizedWords.trim().toLowerCase();
          lastWords.value = text;
          _handleCommand(text);
        }
      },
    );
  }

  Future<void> stopListening() async {
    autoListen.value = false;
    await _speech.stop();
    isListening.value = false;
  }

  Future<void> pauseListening() async {
    await _speech.stop();
    isListening.value = false;
  }

  void _handleCommand(String text) {
    if (text.isEmpty) return;
    final normalized = _canonicalizeCommand(_normalizeCommand(text));

    for (final entry in _activeCommands.entries) {
      final key = _canonicalizeCommand(_normalizeCommand(entry.key));
      if (key.isNotEmpty && normalized == key) {
        entry.value();
        return;
      }
    }

    final sortedEntries = _activeCommands.entries.toList()
      ..sort((a, b) {
        final aKey = _canonicalizeCommand(_normalizeCommand(a.key));
        final bKey = _canonicalizeCommand(_normalizeCommand(b.key));
        final wordCompare = _wordCount(bKey).compareTo(_wordCount(aKey));
        if (wordCompare != 0) return wordCompare;
        return bKey.length.compareTo(aKey.length);
      });

    for (final entry in sortedEntries) {
      if (_matches(normalized, entry.key)) {
        entry.value();
        return;
      }
    }
  }

  bool _matches(String text, String key) {
    final k = _canonicalizeCommand(_normalizeCommand(key));
    if (k.isEmpty || k.length == 1) return false;
    final escaped = RegExp.escape(k);
    return RegExp('(^| )$escaped( |\$)').hasMatch(text);
  }

  String _normalizeCommand(String text) {
    final lowered = text.toLowerCase().trim();
    final cleaned = lowered.replaceAll(RegExp(r'[^a-z0-9 ]'), ' ');
    return cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String _canonicalizeCommand(String text) {
    if (text.isEmpty) return text;

    final tokenAliases = <String, String>{
      'eh': 'a',
      'ha': 'a',
      'be': 'b',
      'bi': 'b',
      'ce': 'c',
      'si': 'c',
      'de': 'd',
      'di': 'd',
    };

    final words = text.split(' ');
    final canonicalWords = words
        .map((word) => tokenAliases[word] ?? word)
        .toList(growable: false);

    return canonicalWords.join(' ').trim();
  }

  int _wordCount(String text) {
    if (text.isEmpty) return 0;
    return text.split(' ').where((word) => word.isNotEmpty).length;
  }
}
