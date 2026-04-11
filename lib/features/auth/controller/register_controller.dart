import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/app_colors.dart';
import '../../../routes/app_routes.dart';

class RegisterController extends GetxController {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final rememberPassword = false.obs;
  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;
  final isLoading = false.obs;

  GlobalKey<FormState> get formKey => _formKey;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  void toggleRememberPassword(bool? value) {
    rememberPassword.value = value ?? false;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kata sandi tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Kata sandi minimal 6 karakter';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi kata sandi tidak boleh kosong';
    }
    if (value != passwordController.text) {
      return 'Kata sandi tidak cocok';
    }
    return null;
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

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;
    isLoading.value = true;
    try {
      final response = await AuthService.register(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        confirmPassword: confirmPasswordController.text,
      );
      debugPrint('Register response: $response');
      if (response['error'] != null) {
        Get.snackbar(
          'Gagal',
          response['error'].toString(),
          backgroundColor: Colors.red[50],
          colorText: AppColors.textBlack,
        );
        return;
      }
      if (response['message'] != null && response['token'] == null) {
        Get.snackbar(
          'Berhasil',
          response['message'].toString(),
          backgroundColor: AppColors.yellow,
          colorText: AppColors.textBlack,
        );
        Get.toNamed(AppRoutes.login);
        return;
      }
      if (response['token'] != null) {
        Get.offNamed(AppRoutes.dashboard);
        return;
      }
      final message =
          response['message']?.toString() ?? 'Registrasi gagal. Coba lagi.';
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

  void navigateToLogin() {
    Get.toNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
