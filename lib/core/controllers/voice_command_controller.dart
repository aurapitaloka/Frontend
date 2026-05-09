import 'dart:async';

import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../services/voice_guide_service.dart';

typedef CommandAction = void Function();

class VoiceCommandController extends GetxController {
  static const Duration _postCommandNoSpeechCooldown = Duration(seconds: 6);
  static const Duration _unrecognizedFeedbackCooldown = Duration(seconds: 4);

  final SpeechToText _speech = SpeechToText();
  final RxBool isListening = false.obs;
  final RxBool autoListen = false.obs;
  final RxString lastWords = ''.obs;
  final RxString error = ''.obs;

  final Map<String, CommandAction> _globalCommands = {};
  final List<Map<String, CommandAction>> _commandStack = [];
  final List<String> _noSpeechPromptStack = [];

  bool _isInitialized = false;
  bool _manualStopRequested = false;
  bool _heardWordsThisSession = false;
  bool _commandHandledThisSession = false;
  bool _pendingNoSpeechFeedback = false;
  bool _pendingUnrecognizedFeedback = false;
  bool _isDeliveringNoSpeechFeedback = false;
  bool _suppressNextNoSpeechFeedback = false;
  bool _muteNoSpeechFeedbackUntilSpeech = false;
  DateTime? _suppressNoSpeechUntil;
  DateTime? _lastUnrecognizedFeedbackAt;
  String _lastProcessedTranscript = '';
  DateTime? _lastProcessedTranscriptAt;

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

  void pushNoSpeechPrompt(String prompt) {
    final normalized = prompt.trim();
    if (normalized.isEmpty) return;
    _noSpeechPromptStack.add(normalized);
  }

  void popNoSpeechPrompt(String prompt) {
    final normalized = prompt.trim();
    if (normalized.isEmpty) return;
    final index = _noSpeechPromptStack.lastIndexOf(normalized);
    if (index >= 0) {
      _noSpeechPromptStack.removeAt(index);
    }
  }

  void registerUserInteraction({
    Duration cooldown = _postCommandNoSpeechCooldown,
  }) {
    _muteNoSpeechFeedbackUntilSpeech = false;
    _pendingNoSpeechFeedback = false;
    _suppressNoSpeechUntil = DateTime.now().add(cooldown);
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

  Future<void> ensureContinuousListening() async {
    autoListen.value = true;
    if (isListening.value) return;
    await startListening();
  }

  Future<void> startListening() async {
    final mic = await Permission.microphone.request();
    if (!mic.isGranted) {
      error.value = 'Izin mikrofon ditolak.';
      return;
    }

    final available = await _initializeSpeech();
    if (!available) {
      error.value = 'Speech recognition tidak tersedia.';
      return;
    }

    error.value = '';
    _manualStopRequested = false;
    _heardWordsThisSession = false;
    _commandHandledThisSession = false;
    _pendingNoSpeechFeedback = false;
    _pendingUnrecognizedFeedback = false;
    _lastProcessedTranscript = '';
    isListening.value = true;
    _speech.listen(
      localeId: 'id-ID',
      listenFor: const Duration(minutes: 5),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      onResult: (result) {
        final text = result.recognizedWords.trim().toLowerCase();
        final hasWords = text.isNotEmpty;
        if (hasWords) {
          _heardWordsThisSession = true;
          _pendingNoSpeechFeedback = false;
          _muteNoSpeechFeedbackUntilSpeech = false;
          lastWords.value = text;
        } else if (result.finalResult && !_commandHandledThisSession) {
          _pendingNoSpeechFeedback = true;
        }

        final shouldHandle =
            hasWords &&
            (result.finalResult || _isFastPartialCommand(text)) &&
            !_isRecentlyProcessedTranscript(text);
        if (shouldHandle) {
          final handled = _handleCommand(text);
          if (handled) {
            _lastProcessedTranscript = text;
            _lastProcessedTranscriptAt = DateTime.now();
          }
        }
      },
    );
  }

  Future<void> stopListening() async {
    autoListen.value = false;
    _manualStopRequested = true;
    _pendingNoSpeechFeedback = false;
    _pendingUnrecognizedFeedback = false;
    _muteNoSpeechFeedbackUntilSpeech = false;
    await _speech.stop();
    isListening.value = false;
  }

  Future<void> pauseListening() async {
    _manualStopRequested = true;
    _pendingNoSpeechFeedback = false;
    _pendingUnrecognizedFeedback = false;
    await _speech.stop();
    isListening.value = false;
  }

  bool _handleCommand(String text) {
    if (text.isEmpty) return false;
    final normalized = _canonicalizeCommand(_normalizeCommand(text));

    for (final entry in _activeCommands.entries) {
      final key = _canonicalizeCommand(_normalizeCommand(entry.key));
      if (key.isNotEmpty && normalized == key) {
        _markCommandHandled();
        _suppressNextNoSpeechFeedback = true;
        entry.value();
        return true;
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
        _markCommandHandled();
        _suppressNextNoSpeechFeedback = true;
        entry.value();
        return true;
      }
    }

    _markUnrecognizedSpeech();
    return false;
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
      'e': 'a',
      'eh': 'a',
      'ae': 'a',
      'ha': 'a',
      'bee': 'b',
      'be': 'b',
      'bi': 'b',
      'ci': 'c',
      'ce': 'c',
      'si': 'c',
      'the': 'd',
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

  bool _isFastAnswerCandidate(String text) {
    final normalized = _canonicalizeCommand(_normalizeCommand(text));
    return const {'a', 'b', 'c', 'd'}.contains(normalized);
  }

  bool _isFastPartialCommand(String text) {
    if (_isFastAnswerCandidate(text)) return true;

    final normalized = _canonicalizeCommand(_normalizeCommand(text));
    if (normalized.length < 2) return false;

    final activeKeys = _activeCommands.keys;
    for (final key in activeKeys) {
      final candidate = _canonicalizeCommand(_normalizeCommand(key));
      if (candidate.isEmpty) continue;
      if (normalized == candidate) return true;
    }
    return false;
  }

  bool _isRecentlyProcessedTranscript(String text) {
    if (text.isEmpty || text != _lastProcessedTranscript) return false;
    final lastAt = _lastProcessedTranscriptAt;
    if (lastAt == null) return false;
    return DateTime.now().difference(lastAt) < const Duration(milliseconds: 1400);
  }

  Future<bool> _initializeSpeech() async {
    if (_isInitialized) return true;
    final available = await _speech.initialize(
      onError: (e) {
        error.value = e.errorMsg;
        if (_isNoSpeechError(e.errorMsg) && !_commandHandledThisSession) {
          _pendingNoSpeechFeedback = true;
        }
        isListening.value = false;
      },
      onStatus: (status) {
        if (status != 'notListening') return;
        isListening.value = false;
        if (_manualStopRequested) {
          _manualStopRequested = false;
          return;
        }
        if (_suppressNextNoSpeechFeedback) {
          _suppressNextNoSpeechFeedback = false;
          _pendingNoSpeechFeedback = false;
          _pendingUnrecognizedFeedback = false;
          if (autoListen.value) {
            _scheduleRestart();
          }
          return;
        }
        if (_isInPostCommandCooldown) {
          _pendingNoSpeechFeedback = false;
          _pendingUnrecognizedFeedback = false;
          if (autoListen.value) {
            _scheduleRestart();
          }
          return;
        }
        if (_pendingNoSpeechFeedback && _muteNoSpeechFeedbackUntilSpeech) {
          _pendingNoSpeechFeedback = false;
          _pendingUnrecognizedFeedback = false;
          if (autoListen.value) {
            _scheduleRestart();
          }
          return;
        }
        if (!_heardWordsThisSession && !_commandHandledThisSession) {
          _pendingNoSpeechFeedback = true;
        }
        if (!autoListen.value) return;
        if (_pendingUnrecognizedFeedback) {
          unawaited(_deliverUnrecognizedFeedbackAndResume());
          return;
        }
        if (_pendingNoSpeechFeedback) {
          unawaited(_deliverNoSpeechFeedbackAndResume());
          return;
        }
        _scheduleRestart();
      },
    );
    _isInitialized = available;
    return available;
  }

  bool _isNoSpeechError(String message) {
    final normalized = message.toLowerCase();
    return normalized.contains('no_match') ||
        normalized.contains('speech_timeout') ||
        normalized.contains('error_speech_timeout') ||
        normalized.contains('error_no_match');
  }

  Future<void> _deliverNoSpeechFeedbackAndResume() async {
    if (_isDeliveringNoSpeechFeedback) return;
    _isDeliveringNoSpeechFeedback = true;
    try {
      await VoiceGuideService.instance.stop();
      await VoiceGuideService.instance.speak(_activeNoSpeechPrompt);
      _muteNoSpeechFeedbackUntilSpeech = true;
    } catch (_) {
      // Abaikan error TTS agar sesi voice tetap bisa lanjut.
    } finally {
      _pendingNoSpeechFeedback = false;
      _isDeliveringNoSpeechFeedback = false;
    }
    _scheduleRestart();
  }

  Future<void> _deliverUnrecognizedFeedbackAndResume() async {
    if (_isDeliveringNoSpeechFeedback) return;
    _isDeliveringNoSpeechFeedback = true;
    try {
      await VoiceGuideService.instance.stop();
      await VoiceGuideService.instance.speak(
        'Perintah belum saya pahami. Silakan ucapkan lagi dengan lebih jelas.',
      );
    } catch (_) {
      // Abaikan error TTS agar sesi voice tetap bisa lanjut.
    } finally {
      _pendingNoSpeechFeedback = false;
      _pendingUnrecognizedFeedback = false;
      _isDeliveringNoSpeechFeedback = false;
      _lastUnrecognizedFeedbackAt = DateTime.now();
    }
    _scheduleRestart();
  }

  void _scheduleRestart() {
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (autoListen.value && !isListening.value && !_isDeliveringNoSpeechFeedback) {
        startListening();
      }
    });
  }

  String get _activeNoSpeechPrompt {
    if (_noSpeechPromptStack.isNotEmpty) {
      return _noSpeechPromptStack.last;
    }
    return 'Saya belum mendengar suara. Coba ulangi perintahnya.';
  }

  void _markCommandHandled() {
    _commandHandledThisSession = true;
    _pendingNoSpeechFeedback = false;
    _pendingUnrecognizedFeedback = false;
    registerUserInteraction();
  }

  void _markUnrecognizedSpeech() {
    if (_isInPostCommandCooldown) return;
    final now = DateTime.now();
    final last = _lastUnrecognizedFeedbackAt;
    if (last != null && now.difference(last) < _unrecognizedFeedbackCooldown) {
      return;
    }
    _pendingNoSpeechFeedback = false;
    _pendingUnrecognizedFeedback = true;
  }

  bool get _isInPostCommandCooldown {
    final until = _suppressNoSpeechUntil;
    if (until == null) return false;
    if (DateTime.now().isAfter(until)) {
      _suppressNoSpeechUntil = null;
      return false;
    }
    return true;
  }
}
