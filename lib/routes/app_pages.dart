import 'package:get/get.dart';
import '../features/auth/view/welcome_view.dart';
import '../features/auth/view/login_view.dart';
import '../features/auth/view/register_view.dart';
import '../features/auth/binding/login_binding.dart';
import '../features/auth/binding/register_binding.dart';
import '../features/dashboard/view/dashboard_view.dart';
import '../features/dashboard/binding/dashboard_binding.dart';
import '../features/profile/view/edit_profile_view.dart';
import '../features/profile/binding/edit_profile_binding.dart';
import '../features/profile/view/profile_about_view.dart';
import '../features/profile/view/profile_quiz_view.dart';
import '../features/profile/view/profile_notes_view.dart';
import '../features/profile/view/profile_voice_settings_view.dart';
import '../features/profile/binding/profile_quiz_binding.dart';
import '../features/profile/binding/profile_notes_binding.dart';
import '../features/profile/view/profile_quiz_detail_view.dart';
import '../features/profile/view/profile_quiz_history_view.dart';
import '../features/profile/view/profile_quiz_history_detail_view.dart';
import '../features/profile/binding/profile_quiz_detail_binding.dart';
import '../features/profile/binding/profile_quiz_history_binding.dart';
import '../features/profile/binding/profile_quiz_history_detail_binding.dart';
import '../features/material_detail/view/material_detail_view.dart';
import '../features/material_detail/binding/material_detail_binding.dart';
import '../features/material_book/view/material_book_view.dart';
import '../features/material_book/binding/material_book_binding.dart';
import '../features/webview/view/feature_webview.dart';
import '../features/aac/binding/aac_binding.dart';
import '../features/aac/view/aac_view.dart';
import '../features/panduan/binding/panduan_binding.dart';
import '../features/panduan/view/panduan_view.dart';
import '../features/quiz/binding/materi_quiz_intro_binding.dart';
import '../features/quiz/view/materi_quiz_intro_view.dart';
import 'app_routes.dart';

class AppPages {
  static final List<GetPage> routes = [
    GetPage(name: AppRoutes.welcome, page: () => const WelcomeView()),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfileView(),
      binding: EditProfileBinding(),
    ),
    GetPage(name: AppRoutes.profileAbout, page: () => const ProfileAboutView()),
    GetPage(
      name: AppRoutes.profileQuiz,
      page: () => const ProfileQuizView(),
      binding: ProfileQuizBinding(),
    ),
    GetPage(
      name: AppRoutes.profileNotes,
      page: () => const ProfileNotesView(),
      binding: ProfileNotesBinding(),
    ),
    GetPage(
      name: AppRoutes.profileVoiceSettings,
      page: () => const ProfileVoiceSettingsView(),
    ),
    GetPage(
      name: AppRoutes.profileQuizDetail,
      page: () => const ProfileQuizDetailView(),
      binding: ProfileQuizDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.profileQuizHistory,
      page: () => const ProfileQuizHistoryView(),
      binding: ProfileQuizHistoryBinding(),
    ),
    GetPage(
      name: AppRoutes.profileQuizHistoryDetail,
      page: () => const ProfileQuizHistoryDetailView(),
      binding: ProfileQuizHistoryDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.material,
      page: () => const MaterialBookView(),
      binding: MaterialBookBinding(),
    ),
    GetPage(
      name: AppRoutes.materialDetail,
      page: () => const MaterialDetailView(),
      binding: MaterialDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.aac,
      page: () => const AacView(),
      binding: AacBinding(),
    ),
    GetPage(
      name: AppRoutes.panduan,
      page: () => const PanduanView(),
      binding: PanduanBinding(),
    ),
    GetPage(
      name: AppRoutes.materiQuizIntro,
      page: () => const MateriQuizIntroView(),
      binding: MateriQuizIntroBinding(),
    ),
    GetPage(name: AppRoutes.webview, page: () => const FeatureWebView()),
  ];
}
