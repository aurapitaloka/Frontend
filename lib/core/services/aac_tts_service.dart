import 'aac_tts_service_stub.dart'
    if (dart.library.html) 'aac_tts_service_web.dart';

abstract class AacTtsService {
  Future<void> speak(String text);
  Future<void> stop();
}

AacTtsService createAacTtsService() => createAacTtsServiceImpl();
