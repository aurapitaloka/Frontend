// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:akses_frontend/routes/app_pages.dart';
import 'package:akses_frontend/routes/app_routes.dart';

void main() {
  testWidgets('Halaman Register muncul dan memuat field utama', (
    WidgetTester tester,
  ) async {
    // Bangun aplikasi dengan rute awal register.
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: AppRoutes.register,
        getPages: AppPages.routes,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF6B00)),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
      ),
    );

    // Pastikan transisi route selesai.
    await tester.pumpAndSettle();

    // Field-field utama register harus tampil.
    expect(find.text('Nama'), findsOneWidget);
    expect(find.text('Kata Sandi'), findsOneWidget);
    expect(find.text('Konfirmasi Kata Sandi'), findsOneWidget);
    expect(find.text('Register'), findsWidgets);
  });
}
