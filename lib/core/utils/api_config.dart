class ApiConfig {
  // Ganti dengan URL backend Anda
  static const String baseUrl = 'https://8d93-114-10-20-130.ngrok-free.app/api';
  static String get baseHost =>
      baseUrl.endsWith('/api')
          ? baseUrl.substring(0, baseUrl.length - 4)
          : baseUrl;

  // Endpoints
  static const String loginEndpoint = '/login';
  static const String registerEndpoint = '/register';
  static const String logoutEndpoint = '/logout';
  static const String profileEndpoint = '/dashboard/profile';
  static const String materiEndpoint = '/dashboard/materi';
  static const String levelEndpoint = '/level';
  static const String fiksiEndpoint = '/fiksi';
  static const String rakBukuEndpoint = '/dashboard/rak-buku';

  static String? resolveStorageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;//
    return '$baseHost/storage/$path';
  }
}
