import 'dart:io';

import '../utils/api_config.dart';
import 'api_service.dart';
import 'token_storage.dart';

class AuthService {
  // Login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiService.post(ApiConfig.loginEndpoint, {
      'email': email,
      'kata_sandi': password,
    });
    final token = response['token'];
    if (token is String && token.isNotEmpty) {
      await TokenStorage.saveToken(token);
    }
    return response;
  }

  // Register
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    return await ApiService.post(ApiConfig.registerEndpoint, {
      'nama': name,
      'email': email,
      'kata_sandi': password,
      'kata_sandi_konfirmasi': confirmPassword,
    });
  }

  // Logout
  static Future<Map<String, dynamic>> logout() async {
    final response = await ApiService.post(ApiConfig.logoutEndpoint, {});
    await TokenStorage.clearToken();
    return response;
  }

  // Get User Profile
  static Future<Map<String, dynamic>> getProfile() async {
    return await ApiService.get(ApiConfig.profileEndpoint);
  }

  // Update Profile
  static Future<Map<String, dynamic>> updateProfile(
    Map<String, String> data,
  ) async {
    return await ApiService.multipartRequest(
      'PUT',
      ApiConfig.profileEndpoint,
      fields: data,
    );
  }

  // Upload profile photo
  static Future<Map<String, dynamic>> uploadProfilePhoto(String filePath) async {
    final file = File(filePath);
    return await ApiService.multipartRequest(
      'POST',
      ApiConfig.profileEndpoint + '/upload-foto',
      files: {'foto_profil': file},
    );
  }

  // Update password
  static Future<Map<String, dynamic>> updatePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    return await ApiService.put(
      ApiConfig.profileEndpoint + '/password',
      {
        'kata_sandi_lama': oldPassword,
        'kata_sandi_baru': newPassword,
        'kata_sandi_konfirmasi': confirmPassword,
      },
    );
  }
}
