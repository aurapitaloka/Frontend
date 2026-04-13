import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/app_colors.dart';
import '../../../routes/app_routes.dart';

class LoginController extends GetxController {
  static const _prefRemember = 'login_remember';
  static const _prefEmail = 'login_email';
  static const _prefPassword = 'login_password';

  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final rememberPassword = true.obs;
  final obscurePassword = true.obs;
  final isLoading = false.obs;

  GlobalKey<FormState> get formKey => _formKey;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleRememberPassword(bool? value) {
    rememberPassword.value = value ?? false;
    if (!rememberPassword.value) {
      _clearSavedCredentials();
    }
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kata sandi tidak boleh kosong';
    }
    return null;
  }

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;
    isLoading.value = true;
    try {
      final response = await AuthService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      debugPrint('Login response: $response');
      if (response['error'] != null) {
        Get.snackbar(
          'Gagal',
          response['error'].toString(),
          backgroundColor: Colors.red[50],
          colorText: AppColors.textBlack,
        );
        return;
      }
      if (response['token'] != null) {
        await _persistCredentialsIfNeeded();
        Get.offNamed(AppRoutes.dashboard, arguments: {'showGuide': true});
        return;
      }
      final message =
          response['message']?.toString() ?? 'Login gagal. Coba lagi.';
      Get.snackbar(
        'Gagal',
        message,
        backgroundColor: Colors.red[50],
        colorText: AppColors.textBlack,
      );
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Terjadi kesalahan: $e',
        backgroundColor: Colors.red[50],
        colorText: AppColors.textBlack,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _persistCredentialsIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    if (rememberPassword.value) {
      await prefs.setBool(_prefRemember, true);
      await prefs.setString(_prefEmail, emailController.text.trim());
      await prefs.setString(_prefPassword, passwordController.text);
    } else {
      await _clearSavedCredentials();
    }
  }

  Future<void> _clearSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefRemember);
    await prefs.remove(_prefEmail);
    await prefs.remove(_prefPassword);
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool(_prefRemember) ?? false;
    rememberPassword.value = remember;
    if (remember) {
      emailController.text = prefs.getString(_prefEmail) ?? '';
      passwordController.text = prefs.getString(_prefPassword) ?? '';
    }
  }

  @override
  void onInit() {
    super.onInit();
    _loadSavedCredentials();
  }

  void navigateToRegister() {
    Get.toNamed(AppRoutes.register);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
