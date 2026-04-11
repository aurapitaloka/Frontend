import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../auth/view/welcome_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  Timer? _timer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    // Start navigation after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startNavigation();
    });
  }

  void _startNavigation() {
    _timer = Timer(const Duration(seconds: 5), () {
      if (!mounted || _hasNavigated) return;
      _hasNavigated = true;

      debugPrint('=== SPLASH NAVIGATION ===');
      debugPrint('Current route: ${Get.currentRoute}');
      debugPrint('Target route: ${AppRoutes.welcome}');

      // Try GetX navigation first
      try {
        Get.offAllNamed(AppRoutes.welcome);
        debugPrint('✅ Navigation successful with Get.offAllNamed');
      } catch (e) {
        debugPrint('❌ GetX navigation failed: $e');
        // Fallback: Direct widget navigation
        try {
          Get.offAll(() => const WelcomeView());
          debugPrint('✅ Navigation successful with Get.offAll');
        } catch (e2) {
          debugPrint('❌ Get.offAll failed: $e2');
          // Last resort: Use Navigator
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const WelcomeView()),
              (route) => false,
            );
            debugPrint('✅ Navigation successful with Navigator');
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFEB3B), // Yellow background
      body: Center(
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            // White circle
            Positioned(
              left: MediaQuery.of(context).size.width * 0.1,
              child: Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Text overlay
            Positioned(
              left: MediaQuery.of(context).size.width * 0.15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Selamat Datang di',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'AKSES',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6B00), // Orange color
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
