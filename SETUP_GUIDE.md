# Setup Guide - AKSES Frontend

## Struktur Project

```
lib/
├── main.dart                 # Entry point dengan GetX setup
├── screens/
│   ├── splash_screen.dart   # Screen pertama (Selamat Datang di AKSES)
│   └── welcome_screen.dart  # Screen kedua (Login/Register)
├── routes/
│   ├── app_routes.dart      # Definisi route names
│   └── app_pages.dart       # Konfigurasi GetX routes
├── services/
│   ├── api_service.dart     # Service untuk HTTP requests
│   └── auth_service.dart    # Service untuk authentication
└── utils/
    ├── api_config.dart      # Konfigurasi API URL
    └── app_colors.dart      # Warna aplikasi

assets/
└── images/                  # Folder untuk file gambar webp
    ├── README.md
    ├── welcome_illustration.webp  (tambahkan file ini)
    └── logo_hand.webp             (opsional)
```

## Cara Menggunakan

### 1. Menambahkan Gambar
- Letakkan file gambar webp di folder `assets/images/`
- File yang diperlukan:
  - `welcome_illustration.webp` - Gambar ilustrasi untuk welcome screen
  - `logo_hand.webp` - Logo tangan (opsional)

### 2. Konfigurasi Backend
- Buka file `lib/utils/api_config.dart`
- Ganti `baseUrl` dengan URL backend Anda

### 3. Menjalankan Aplikasi
```bash
flutter pub get
flutter run
```

## Fitur yang Sudah Dibuat

✅ Splash Screen dengan desain sesuai gambar
✅ Welcome Screen dengan pilihan Login/Register
✅ GetX routing setup
✅ API Service untuk koneksi backend
✅ Auth Service untuk authentication
✅ Folder struktur untuk images
✅ Error handling untuk gambar yang belum ada

## Next Steps

1. Buat screen Login dan Register
2. Tambahkan file gambar webp ke folder `assets/images/`
3. Update `api_config.dart` dengan URL backend yang benar
4. Implementasikan logic untuk Login dan Register

