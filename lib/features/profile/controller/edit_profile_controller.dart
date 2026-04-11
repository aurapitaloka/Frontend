import 'dart:io';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/api_config.dart';
import 'profile_controller.dart';

class EditProfileController extends GetxController {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final obscureNewPassword = true.obs;
  final obscureConfirmPassword = true.obs;

  GlobalKey<FormState> get formKey => _formKey;

  void toggleNewPasswordVisibility() {
    obscureNewPassword.value = !obscureNewPassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  String? validatePassword(String? value) {
    if (value != null && value.isNotEmpty) {
      if (value.length < 6) {
        return 'Password minimal 6 karakter';
      }
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value != null && value.isNotEmpty) {
      if (value != newPasswordController.text) {
        return 'Password tidak cocok';
      }
    }
    return null;
  }

  String? validateCurrentPassword(String? value) {
    if (newPasswordController.text.trim().isNotEmpty) {
      if (value == null || value.trim().isEmpty) {
        return 'Password lama wajib diisi';
      }
    }
    return null;
  }

  void saveProfile() {
    if (_formKey.currentState!.validate()) {
      _saveToServer();
    }
  }

  Future<void> _saveToServer() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();

    final data = <String, String>{
      'nama': name,
      'email': email,
    };

    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
      final response = await AuthService.updateProfile(data);
      debugPrint('[EditProfile] updateProfile response -> $response');

      // Handle validation errors
      if (response.containsKey('errors')) {
        final errors = response['errors'] as Map<String, dynamic>;
        final firstField = errors.keys.first;
        final firstMsg = (errors[firstField] as List).join('\n');
        Get.back();
        Get.snackbar('Gagal', firstMsg, backgroundColor: Colors.redAccent, colorText: Colors.white);
        return;
      }

      // If backend returns message or redirected response
      // Update password if user filled new password
      final newPassword = newPasswordController.text.trim();
      final currentPassword = currentPasswordController.text.trim();
      if (newPassword.isNotEmpty) {
        final passwordRes = await AuthService.updatePassword(
          oldPassword: currentPassword,
          newPassword: newPassword,
          confirmPassword: confirmPasswordController.text.trim(),
        );
        debugPrint('[EditProfile] updatePassword response -> $passwordRes');
        if (passwordRes.containsKey('errors')) {
          final errors = passwordRes['errors'] as Map<String, dynamic>;
          final firstField = errors.keys.first;
          final firstMsg = (errors[firstField] as List).join('\n');
          Get.back();
          Get.snackbar('Gagal', firstMsg, backgroundColor: Colors.redAccent, colorText: Colors.white);
          return;
        }
      }

      Get.back();
      Get.snackbar('Berhasil', 'Profil berhasil diperbarui', backgroundColor: Colors.green, colorText: Colors.white);

      // Update global profile controller if present
      try {
        final profileCtrl = Get.find<ProfileController>();
        profileCtrl.userName.value = name;
        profileCtrl.userEmail.value = email;
      } catch (_) {}

      // Close edit screen
      Get.back();
    } catch (e) {
      Get.back();
      Get.snackbar('Error', 'Gagal mengirim data: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  void changeProfilePicture() {
    _pickAndUploadImage();
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (picked == null) return;

      // show loading
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

      final response = await AuthService.uploadProfilePhoto(picked.path);
      debugPrint('[EditProfile] uploadPhoto response -> $response');

      Get.back();

      if (response.containsKey('errors')) {
        final errors = response['errors'] as Map<String, dynamic>;
        final firstField = errors.keys.first;
        final firstMsg = (errors[firstField] as List).join('\n');
        Get.snackbar('Gagal', firstMsg, backgroundColor: Colors.redAccent, colorText: Colors.white);
        return;
      }

      // On success, update profile controller and show snackbar
      try {
        final profileCtrl = Get.find<ProfileController>();
        final foto = response['foto_profil']?.toString();
        final resolved = ApiConfig.resolveStorageUrl(foto);
        if (resolved != null && resolved.isNotEmpty) {
          profileCtrl.profileImageUrl.value = resolved;
        }
      } catch (_) {}

      Get.snackbar('Sukses', 'Foto profil berhasil diupload', backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.back();
      Get.snackbar('Error', 'Gagal upload foto: $e', backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final response = await AuthService.getProfile();
      debugPrint('[EditProfile] loadProfile response -> $response');
      final user = response['user'] ?? response;
      if (user is Map<String, dynamic>) {
        final nama = user['nama']?.toString() ?? user['name']?.toString();
        final email = user['email']?.toString();
        if (nama != null && nama.isNotEmpty) {
          nameController.text = nama;
        }
        if (email != null && email.isNotEmpty) {
          emailController.text = email;
        }
      }
    } catch (e) {
      debugPrint('[EditProfile] loadProfile error -> $e');
    }
  }
}
