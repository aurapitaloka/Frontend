import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/edit_profile_controller.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/widgets/primary_header.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  static const Color _bgWarm = Color(0xFFFFF8F3);
  static const Color _borderSoft = Color(0xFFF0E8E0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgWarm,
      body: SafeArea(
        child: Column(
          children: [
            PrimaryHeader(
              title: 'Edit Profil',
              trailing: IconButton(
                onPressed: Get.back,
                icon: const Icon(Icons.close_rounded, color: AppColors.orange),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    children: [
                      _profileHero(),
                      const SizedBox(height: 16),
                      _sectionCard(
                        title: 'Informasi Dasar',
                        subtitle: 'Perbarui data utama profil kamu.',
                        children: [
                          _buildFieldLabel('Nama'),
                          _buildTextField(controller: controller.nameController),
                          const SizedBox(height: 16),
                          _buildFieldLabel('Email'),
                          _buildTextField(
                            controller: controller.emailController,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          _buildFieldLabel('Kelas'),
                          _buildTextField(
                            controller: controller.kelasController,
                            textInputAction: TextInputAction.next,
                            hintText: 'Contoh: 1, 2, 3, atau Kelas 1',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _sectionCard(
                        title: 'Keamanan Akun',
                        subtitle: 'Isi hanya jika ingin mengganti password.',
                        children: [
                          _buildFieldLabel('Password Lama'),
                          Obx(
                            () => _buildTextField(
                              controller: controller.currentPasswordController,
                              hintText: 'Masukkan password lama',
                              obscureText:
                                  controller.obscureNewPassword.value,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.obscureNewPassword.value
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.grey,
                                ),
                                onPressed:
                                    controller.toggleNewPasswordVisibility,
                              ),
                              validator: controller.validateCurrentPassword,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildFieldLabel('Password Baru'),
                          Obx(
                            () => _buildTextField(
                              controller: controller.newPasswordController,
                              hintText: 'Masukkan password baru',
                              obscureText:
                                  controller.obscureNewPassword.value,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.obscureNewPassword.value
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.grey,
                                ),
                                onPressed:
                                    controller.toggleNewPasswordVisibility,
                              ),
                              validator: controller.validatePassword,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildFieldLabel('Konfirmasi Password'),
                          Obx(
                            () => _buildTextField(
                              controller: controller.confirmPasswordController,
                              hintText: 'Masukkan ulang password baru',
                              obscureText:
                                  controller.obscureConfirmPassword.value,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.obscureConfirmPassword.value
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.grey,
                                ),
                                onPressed: controller
                                    .toggleConfirmPasswordVisibility,
                              ),
                              validator: controller.validateConfirmPassword,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: controller.saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Simpan Perubahan',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF3E0), Color(0xFFFFF8E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE0B2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 58,
                  color: AppColors.orange,
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: GestureDetector(
                  onTap: controller.changeProfilePicture,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.orange,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Perbarui Profil Kamu',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.textBlack,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Ubah data profil dan keamanan akun tanpa mengubah informasi belajar kamu.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: Colors.grey[700],
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderSoft),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textBlack,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12.5,
              color: Colors.grey[600],
              height: 1.4,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: AppColors.orange,
        fontFamily: 'Roboto',
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    String? hintText,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFFFFBF7),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _borderSoft),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.orange, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
        ),
      ),
    );
  }
}
