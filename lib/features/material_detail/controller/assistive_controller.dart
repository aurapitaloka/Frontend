// khusus fitur gaze & voice
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class AssistiveController extends GetxController {
  final RxBool gazeEnabled = false.obs;
  final RxBool voiceEnabled = false.obs;

  Future<void> toggleGaze() async {
    if (!gazeEnabled.value) {
      final ok = await _ensurePermission(Permission.camera);
      if (ok) gazeEnabled.value = true;
    } else {
      gazeEnabled.value = false;
    }
  }

  Future<void> toggleVoice() async {
    if (!voiceEnabled.value) {
      final ok = await _ensurePermission(Permission.microphone);
      if (ok) voiceEnabled.value = true;
    } else {
      voiceEnabled.value = false;
    }
  }

  Future<bool> _ensurePermission(Permission permission) async {
    final status = await permission.request();
    return status.isGranted;
  }
}
