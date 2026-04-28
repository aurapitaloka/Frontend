import 'api_service.dart';

class QuizService {
  static Future<Map<String, dynamic>> list() async {
    return ApiService.get('/dashboard-siswa/kuis');
  }

  static Future<Map<String, dynamic>> detail(int kuisId) async {
    return ApiService.get('/dashboard-siswa/kuis/$kuisId');
  }

  static Future<Map<String, dynamic>> materiQuiz(int materiId) async {
    return ApiService.get('/dashboard-siswa/materi/$materiId/kuis');
  }

  static Future<Map<String, dynamic>> materiQuizDetail(
    int materiId,
    int kuisId,
  ) async {
    return ApiService.get('/dashboard-siswa/materi/$materiId/kuis/$kuisId');
  }

  static Future<Map<String, dynamic>> submitByKuisId(
    int kuisId,
    Map<String, dynamic> payload,
  ) async {
    return ApiService.post('/dashboard-siswa/kuis/$kuisId', payload);
  }

  static Future<Map<String, dynamic>> submitByMateriId(
    int materiId,
    Map<String, dynamic> payload,
  ) async {
    return ApiService.post('/dashboard-siswa/materi/$materiId/kuis', payload);
  }

  static Future<Map<String, dynamic>> submitByMateriAndKuisId(
    int materiId,
    int kuisId,
    Map<String, dynamic> payload,
  ) async {
    return ApiService.post('/dashboard-siswa/materi/$materiId/kuis/$kuisId', payload);
  }

  static Future<Map<String, dynamic>> history({
    String sort = 'latest',
    int perPage = 8,
  }) async {
    return ApiService.get(
      '/dashboard-siswa/riwayat/kuis?kuis_sort=$sort&per_page=$perPage',
    );
  }

  static Future<Map<String, dynamic>> historyDetail(int hasilId) async {
    return ApiService.get('/dashboard-siswa/riwayat/kuis/$hasilId');
  }
}
