import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/voice_command_controller.dart';
import '../utils/app_colors.dart';

class VoiceCommandButton extends GetView<VoiceCommandController> {
  final double size;

  const VoiceCommandButton({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: controller.toggleListening,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: controller.isListening.value
                ? AppColors.orange.withOpacity(0.15)
                : Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            controller.isListening.value ? Icons.mic_rounded : Icons.mic_none_rounded,
            color: AppColors.orange,
            size: 22,
          ),
        ),
      ),
    );
  }
}
