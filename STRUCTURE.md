# Struktur Folder Flutter dengan GetX

## Struktur Project AKSES Frontend

```
lib/
├── main.dart                    # Entry point dengan GetMaterialApp
├── controllers/                 # GetX Controllers untuk state management
│   └── dashboard_controller.dart
├── screens/                     # UI Screens/Views
│   ├── splash_screen.dart
│   ├── welcome_screen.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── dashboard_screen.dart
│   ├── rak_buku_screen.dart
│   └── panduan_screen.dart
├── routes/                      # GetX Routing
│   ├── app_routes.dart         # Definisi route names
│   └── app_pages.dart          # Konfigurasi GetX routes
├── services/                    # Business Logic & API Services
│   ├── api_service.dart        # HTTP requests service
│   └── auth_service.dart       # Authentication service
└── utils/                       # Utilities & Helpers
    ├── api_config.dart         # API configuration
    └── app_colors.dart         # App color constants

assets/
└── images/                      # Image assets
    ├── welcome_illustration.webp
    └── logo_hand.webp
```

## Pola yang Digunakan

### 1. **Routing dengan GetX**
- Menggunakan `GetMaterialApp` di `main.dart`
- Route definitions di `app_routes.dart`
- Route pages di `app_pages.dart`
- Navigation menggunakan `Get.toNamed()` atau `Get.offNamed()`

### 2. **State Management**
- **Hybrid Approach**: 
  - GetX untuk routing (wajib)
  - StatefulWidget/StatelessWidget untuk UI (untuk screen sederhana)
  - GetX Controllers untuk state management kompleks (opsional)

### 3. **Screen Pattern**
- **StatelessWidget**: Untuk screen statis (PanduanScreen, RakBukuScreen)
- **StatefulWidget**: Untuk screen dengan state lokal (DashboardScreen, LoginScreen)
- **GetView + Controller**: Untuk screen dengan state management kompleks (opsional)

## Contoh Penggunaan

### Routing
```dart
// Navigate
Get.toNamed(AppRoutes.dashboard);

// Back
Get.back();
```

### State Management dengan GetX (Opsional)
```dart
// Controller
class DashboardController extends GetxController {
  final RxInt selectedIndex = 0.obs;
  
  void changeIndex(int index) {
    selectedIndex.value = index;
  }
}

// View dengan GetView
class DashboardView extends GetView<DashboardController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => Text('Index: ${controller.selectedIndex.value}'));
  }
}
```

## Catatan

- Proyek ini menggunakan **GetX untuk routing** (wajib)
- Screen menggunakan **StatefulWidget/StatelessWidget** (hybrid approach)
- Controllers tersedia untuk state management kompleks jika diperlukan
- Struktur folder mengikuti best practices Flutter + GetX

