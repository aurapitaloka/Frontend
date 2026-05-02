import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/api_config.dart';
import '../../../routes/app_routes.dart';

class ProfileController extends GetxController {
  // User data
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  final RxString userKelas = ''.obs;
  final RxString profileImageUrl = ''.obs; // Empty = use placeholder
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Statistics
  final RxInt completedMaterials = 2.obs;
  final RxInt pendingMaterials = 1.obs;
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await AuthService.getProfile();
      debugPrint('[Profile] fetchProfile response -> $response');
      final userCandidate = response['user'] ?? response;
      if (userCandidate is Map<String, dynamic>) {
        userName.value =
            userCandidate['nama']?.toString() ??
            userCandidate['name']?.toString() ??
            userName.value;
        userEmail.value = userCandidate['email']?.toString() ?? userEmail.value;
        userKelas.value = _extractKelas(userCandidate);
        final foto = userCandidate['foto_profil']?.toString();
        final resolved = ApiConfig.resolveStorageUrl(foto);
        if (resolved != null && resolved.isNotEmpty) {
          profileImageUrl.value = resolved;
        }
      } else {
        errorMessage.value =
            response['message']?.toString() ??
            response['error']?.toString() ??
            'Gagal memuat profile';
      }
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToEditProfile() {
    Get.toNamed(AppRoutes.editProfile);
  }

  void navigateToProfileSettings() {
    Get.toNamed(AppRoutes.editProfile);
  }

  void navigateToAboutUs() {
    Get.toNamed(AppRoutes.profileAbout);
  }

  Future<void> logout() async {
    try {
      await AuthService.logout();
    } finally {
      Get.offAllNamed(AppRoutes.welcome);
    }
  }

  void changeBottomNavIndex(int index) {
    // This will be handled by DashboardController
    // But we can add logic here if needed
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  String _extractKelas(Map<String, dynamic> user) {
    final direct =
        user['kelas']?.toString() ??
        user['class']?.toString() ??
        user['class_name']?.toString() ??
        user['kelas_nama']?.toString();
    if (direct != null && direct.isNotEmpty && direct != 'null') {
      return direct;
    }

    final level = user['level'];
    if (level is Map<String, dynamic>) {
      final name = level['nama']?.toString() ?? level['name']?.toString();
      if (name != null && name.isNotEmpty && name != 'null') {
        return name;
      }
    }

    final levelId =
        user['level_id']?.toString() ??
        user['kelas_id']?.toString() ??
        user['class_id']?.toString();
    if (levelId != null && levelId.isNotEmpty && levelId != 'null') {
      return levelId;
    }

    return '';
  }
}
