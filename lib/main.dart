import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'core/controllers/voice_command_controller.dart';
import 'features/dashboard/controller/dashboard_controller.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    AndroidWebViewPlatform.registerWith();
  }
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Optional: app tetap jalan walau .env belum ada
  }
  final voice = Get.put(VoiceCommandController(), permanent: true);

  void openDashboardTab(int index) {
    if (Get.currentRoute == AppRoutes.dashboard &&
        Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().changeIndex(index);
      return;
    }

    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().changeIndex(index);
    }

    Get.offNamed(
      AppRoutes.dashboard,
      arguments: {'initialIndex': index},
    );
  }

  voice.setGlobalCommands({
    'dashboard': () => openDashboardTab(0),
    'beranda': () => openDashboardTab(0),
    'home': () => openDashboardTab(0),
    'halaman utama': () => openDashboardTab(0),
    'menu utama': () => openDashboardTab(0),
    'buka dashboard': () => openDashboardTab(0),
    'buka beranda': () => openDashboardTab(0),
    'buka home': () => openDashboardTab(0),
    'rak buku': () => openDashboardTab(1),
    'menu rak buku': () => openDashboardTab(1),
    'buka rak buku': () => openDashboardTab(1),
    'buka menu rak buku': () => openDashboardTab(1),
    'aac': () => openDashboardTab(2),
    'komunikasi': () => openDashboardTab(2),
    'menu aac': () => openDashboardTab(2),
    'menu komunikasi': () => openDashboardTab(2),
    'buka aac': () => openDashboardTab(2),
    'buka komunikasi': () => openDashboardTab(2),
    'buka menu aac': () => openDashboardTab(2),
    'buka menu komunikasi': () => openDashboardTab(2),
    'buka aac komunikasi': () => openDashboardTab(2),
    'profil': () => openDashboardTab(3),
    'profile': () => openDashboardTab(3),
    'menu profil': () => openDashboardTab(3),
    'menu profile': () => openDashboardTab(3),
    'buka profil': () => openDashboardTab(3),
    'buka profile': () => openDashboardTab(3),
    'buka menu profil': () => openDashboardTab(3),
    'buka menu profile': () => openDashboardTab(3),
    'panduan': () => Get.toNamed(AppRoutes.panduan),
    'menu panduan': () => Get.toNamed(AppRoutes.panduan),
    'buka panduan': () => Get.toNamed(AppRoutes.panduan),
    'buka menu panduan': () => Get.toNamed(AppRoutes.panduan),
    'edit profil': () => Get.toNamed(AppRoutes.editProfile),
    'edit profile': () => Get.toNamed(AppRoutes.editProfile),
    'ubah profil': () => Get.toNamed(AppRoutes.editProfile),
    'ubah profile': () => Get.toNamed(AppRoutes.editProfile),
    'buka edit profil': () => Get.toNamed(AppRoutes.editProfile),
    'buka edit profile': () => Get.toNamed(AppRoutes.editProfile),
    'kuis': () => Get.toNamed(AppRoutes.profileQuiz),
    'buka kuis': () => Get.toNamed(AppRoutes.profileQuiz),
    'menu kuis': () => Get.toNamed(AppRoutes.profileQuiz),
    'catatan': () => Get.toNamed(AppRoutes.profileNotes),
    'buka catatan': () => Get.toNamed(AppRoutes.profileNotes),
    'menu catatan': () => Get.toNamed(AppRoutes.profileNotes),
    'pengaturan suara': () => Get.toNamed(AppRoutes.profileVoiceSettings),
    'setelan suara': () => Get.toNamed(AppRoutes.profileVoiceSettings),
    'buka pengaturan suara': () => Get.toNamed(AppRoutes.profileVoiceSettings),
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
      title: 'Ruma',
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
