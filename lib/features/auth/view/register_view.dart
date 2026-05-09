import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/register_controller.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/widgets/voice_command_scope.dart';
import '../../../core/widgets/voice_command_button.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  RegisterController get _controller {
    if (!Get.isRegistered<RegisterController>()) {
      Get.put(RegisterController(), permanent: false);
    }
    return Get.find<RegisterController>();
  }

  @override
  Widget build(BuildContext context) {
    final registerController = _controller;

    return VoiceCommandScope(
      commands: {
        'register': () => registerController.register(),
        'daftar': () => registerController.register(),
        'login': () => registerController.navigateToLogin(),
        'masuk': () => registerController.navigateToLogin(),
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF8F3),
        body: Stack(
          children: [
            // Background decorative bubbles
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: AppColors.yellow.withOpacity(0.45),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 80,
              left: -50,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: AppColors.orange.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Main content
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: registerController.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),

                      // ── Voice button ──────────────────────────────────────
                      Align(
                        alignment: Alignment.centerRight,
                        child: _VoicePulseButton(
                          child: VoiceCommandButton(size: 44),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ── Hero section ──────────────────────────────────────
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Image.asset(
                              'assets/images/app_logo.png',
                              width: 72,
                              height: 72,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.white,
                                  child: const Icon(
                                    Icons.pan_tool,
                                    color: AppColors.orange,
                                    size: 36,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Buat akun baru di',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF999999),
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Nunito',
                        ),
                      ),
                      const SizedBox(height: 2),
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Nunito',
                            height: 1.1,
                          ),
                          children: [
                            TextSpan(
                              text: 'Aplikasi Belajar ',
                              style: TextStyle(color: Color(0xFF1A1A2E)),
                            ),
                            TextSpan(
                              text: 'Ruma',
                              style: TextStyle(color: AppColors.orange),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ── Voice command hint ────────────────────────────────
                      _VoiceHintBanner(),

                      const SizedBox(height: 18),

                      // ── Nama field ────────────────────────────────────────
                      _FieldLabel(label: 'Nama'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: registerController.nameController,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: _inputDecoration(
                          hint: 'Masukkan nama kamu',
                          icon: Icons.person_outline_rounded,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama tidak boleh kosong';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 14),

                      // ── Email field ───────────────────────────────────────
                      _FieldLabel(label: 'Email'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: registerController.emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: registerController.validateEmail,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: _inputDecoration(
                          hint: 'Masukkan email kamu',
                          icon: Icons.mail_outline_rounded,
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── Kata Sandi field ──────────────────────────────────
                      _FieldLabel(label: 'Kata Sandi'),
                      const SizedBox(height: 6),
                      Obx(() => TextFormField(
                            controller: registerController.passwordController,
                            obscureText:
                                registerController.obscurePassword.value,
                            validator: registerController.validatePassword,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: _inputDecoration(
                              hint: 'Masukkan kata sandi',
                              icon: Icons.lock_outline_rounded,
                              suffix: IconButton(
                                onPressed: registerController
                                    .togglePasswordVisibility,
                                icon: Icon(
                                  registerController.obscurePassword.value
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: const Color(0xFFCCCCCC),
                                  size: 22,
                                ),
                              ),
                            ),
                          )),

                      const SizedBox(height: 14),

                      // ── Konfirmasi Kata Sandi field ───────────────────────
                      _FieldLabel(label: 'Konfirmasi Kata Sandi'),
                      const SizedBox(height: 6),
                      Obx(() => TextFormField(
                            controller:
                                registerController.confirmPasswordController,
                            obscureText: registerController
                                .obscureConfirmPassword.value,
                            validator:
                                registerController.validateConfirmPassword,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                            decoration: _inputDecoration(
                              hint: 'Ulangi kata sandi',
                              icon: Icons.lock_outline_rounded,
                              suffix: IconButton(
                                onPressed: registerController
                                    .toggleConfirmPasswordVisibility,
                                icon: Icon(
                                  registerController
                                          .obscureConfirmPassword.value
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: const Color(0xFFCCCCCC),
                                  size: 22,
                                ),
                              ),
                            ),
                          )),

                      const SizedBox(height: 14),

                      // ── Remember password ─────────────────────────────────
                      Obx(() => GestureDetector(
                            onTap: () =>
                                registerController.toggleRememberPassword(
                                    !registerController
                                        .rememberPassword.value),
                            child: Row(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: registerController
                                            .rememberPassword.value
                                        ? AppColors.orange
                                        : Colors.white,
                                    border: Border.all(
                                      color: AppColors.orange,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: registerController
                                          .rememberPassword.value
                                      ? const Icon(Icons.check_rounded,
                                          color: Colors.white, size: 14)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Ingat kata sandi',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF555555),
                                    fontFamily: 'Nunito',
                                  ),
                                ),
                              ],
                            ),
                          )),

                      const SizedBox(height: 22),

                      // ── Register button ───────────────────────────────────
                      Obx(() => _RegisterButton(
                            isLoading: registerController.isLoading.value,
                            onPressed: registerController.isLoading.value
                                ? null
                                : registerController.register,
                          )),

                      const SizedBox(height: 16),

                      // ── Login link ────────────────────────────────────────
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Sudah punya akun? ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF888888),
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Nunito',
                              ),
                            ),
                            GestureDetector(
                              onTap: registerController.navigateToLogin,
                              child: const Text(
                                'Masuk sekarang',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.orange,
                                  fontFamily: 'Nunito',
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
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

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFFCCCCCC),
        fontSize: 15,
        fontFamily: 'Nunito',
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: Icon(icon, color: const Color(0xFFCCCCCC), size: 22),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFF0E8E0), width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFF0E8E0), width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.orange, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _VoicePulseButton extends StatefulWidget {
  final Widget child;
  const _VoicePulseButton({required this.child});

  @override
  State<_VoicePulseButton> createState() => _VoicePulseButtonState();
}

class _VoicePulseButtonState extends State<_VoicePulseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ScaleTransition(
          scale: _scale,
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.orange.withOpacity(0.25),
                width: 2,
              ),
            ),
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.orange,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.orange.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: widget.child,
        ),
      ],
    );
  }
}

class _VoiceHintBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFFD166),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.volume_up_rounded,
              color: AppColors.orange, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text.rich(
              TextSpan(
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF888888),
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Nunito',
                  height: 1.4,
                ),
                children: [
                  TextSpan(text: 'Ucapkan '),
                  TextSpan(
                    text: '"daftar"',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.orange,
                    ),
                  ),
                  TextSpan(text: ' atau '),
                  TextSpan(
                    text: '"masuk"',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.orange,
                    ),
                  ),
                  TextSpan(text: ' untuk navigasi'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w900,
        color: Color(0xFF333333),
        fontFamily: 'Nunito',
      ),
    );
  }
}

class _RegisterButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;

  const _RegisterButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.yellow,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE0B84A).withOpacity(0.8),
              blurRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: AppColors.orange,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.app_registration_rounded,
                        color: Color(0xFF1A1A2E), size: 22),
                    SizedBox(width: 10),
                    Text(
                      'Daftar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1A1A2E),
                        fontFamily: 'Nunito',
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
