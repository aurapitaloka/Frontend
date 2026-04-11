import 'api_service.dart';

class CatatanService {
  static Future<Map<String, dynamic>> list({
    int page = 1,
    int perPage = 8,
  }) async {
    return ApiService.get('/dashboard-siswa/catatan?page=$page&per_page=$perPage');
  }

  static Future<Map<String, dynamic>> listWithMateri({
    int page = 1,
    int perPage = 8,
  }) async {
    return ApiService.get(
      '/dashboard-siswa/catatan?page=$page&per_page=$perPage&with_materi_list=1',
    );
  }

  static Future<Map<String, dynamic>> create({
    int? materiId,
    required String isi,
  }) async {
    final payload = <String, dynamic>{
      'isi': isi,
      if (materiId != null) 'materi_id': materiId,
    };
    return ApiService.post('/dashboard-siswa/catatan', payload);
  }

  static Future<Map<String, dynamic>> delete(int catatanId) async {
    return ApiService.delete('/dashboard-siswa/catatan/$catatanId');
  }
}
