import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/voice_command_controller.dart';

class VoiceCommandScope extends StatefulWidget {
  final Map<String, VoidCallback> commands;
  final Widget child;

  const VoiceCommandScope({
    super.key,
    required this.commands,
    required this.child,
  });

  @override
  State<VoiceCommandScope> createState() => _VoiceCommandScopeState();
}

class _VoiceCommandScopeState extends State<VoiceCommandScope> {
  late final VoiceCommandController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<VoiceCommandController>();
    controller.pushCommands(widget.commands);
  }

  @override
  void didUpdateWidget(covariant VoiceCommandScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.commands, widget.commands)) {
      controller.popCommands(oldWidget.commands);
      controller.pushCommands(widget.commands);
    }
  }

  @override
  void dispose() {
    controller.popCommands(widget.commands);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
