import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/controllers/voice_command_controller.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Optional: app tetap jalan walau .env belum ada
  }
  final voice = Get.put(VoiceCommandController(), permanent: true);
  voice.setGlobalCommands({
    'kembali': () => Get.back(),
    'tutup': () => Get.back(),
    'stop': () => voice.stopListening(),
    'berhenti': () => voice.stopListening(),
    'diam': () => voice.stopListening(),
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AKSES',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6B00), // Orange
          primary: const Color(0xFFFF6B00),
          secondary: const Color(0xFFFFEB3B), // Yellow
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
      defaultTransition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
