# API - Materi, Level, Mata Pelajaran (Ringkas)

Dokumentasi ini fokus pada endpoint yang relevan untuk halaman Materi pada aplikasi frontend.

Base URL
```
http://127.0.0.1:8000
```

Autentikasi
- Saat ini backend menggunakan session-based (web). Untuk API lebih baik gunakan token/Sanctum.

1) Materi

- GET /dashboard/materi
  - Query params: `page`, `per_page`, bisa juga `level_id` atau `mata_pelajaran_id` jika disupport
  - Headers: `Cookie` (session) atau `Authorization: Bearer <token>` (API)
  - Success (200) -> JSON paginated, `data` berisi objek materi
  - Pastikan setiap item `file_path` / `url` dapat diakses: `http://127.0.0.1:8000/storage/materi/<file>`

Contoh curl (session):
```
curl -v "http://127.0.0.1:8000/dashboard/materi?per_page=20" -b cookies.txt
```

Contoh curl (API token):
```
curl -v "http://127.0.0.1:8000/api/materi?per_page=20" -H "Authorization: Bearer YOUR_TOKEN" -H "Accept: application/json"
```

Periksa saat `class_id=1` (Kelas 1):
- Pastikan frontend mengirim parameter yang benar (`level_id` atau `class_id`) saat memilih Kelas 1.
- Jika response kosong (data: []), cek: apakah materi belum `status_aktif`, apakah `level_id` cocok, atau apakah file belum diupload.

2) Single Materi

- GET /dashboard/materi/{id}
  - Returns full materi object termasuk `file_path`, `level`, `mata_pelajaran`, `pengguna`.

3) Level

- GET /dashboard/level
  - Mengembalikan list level (contoh: Kelas 1, Kelas 2...)
  - Pastikan frontend mengambil daftar ini untuk dropdown/filternya.

Contoh curl:
```
curl "http://127.0.0.1:8000/dashboard/level" -b cookies.txt
```

4) Mata Pelajaran

- GET /dashboard/mata-pelajaran
  - Mengembalikan list mata pelajaran (contoh: Matematika, IPA)
  - Pastikan mapping `mata_pelajaran_id` di materi sesuai data ini.

Contoh curl:
```
curl "http://127.0.0.1:8000/dashboard/mata-pelajaran" -b cookies.txt
```

Checklist cepat yang harus dikumpulkan jika bermasalah (kirim ke tim backend):
- Langkah reproduksi (layar, pilihan Kelas 1, tombol yang ditekan)
- Waktu request dan device (Android/iOS), versi app
- Request lengkap (method, URL, headers termasuk auth/cookie, query string/body)
- Response lengkap (status code, body JSON)
- HAR file atau curl command output
- Screenshot halaman yang menunjukkan "materi belum tersedia"
- Jika memungkinkan: server log untuk request tersebut

Catatan teknis untuk frontend devs
- Periksa `lib/core/utils/api_config.dart` untuk base URL dan header default.
- Periksa controller/feature yang memanggil endpoint materi (cari kata `materi` di `lib/features` atau `lib/controllers`).
- Jika file tidak muncul di UI: cek apakah frontend membutuhkan `file_path` atau `url` property tertentu (mis. `url` absolute vs `file_path` relatif). Jika relatif, frontend harus menambahkan base `http://127.0.0.1:8000/storage/`.

Jika Anda mau, saya bisa:
- Mencari pemanggilan endpoint `materi` di kode frontend dan mengekstrak contoh request, atau
- Menyusun file Markdown ini menjadi PR/commit di repo.

---
Last updated: 2026-01-02
