import 'api_service.dart';

class BabSummaryService {
  static Future<Map<String, dynamic>> generateSummary({
    required int materiId,
    required int babId,
  }) async {
    return ApiService.post(
      '/dashboard/materi/$materiId/bab/$babId/generate-summary',
      const <String, dynamic>{},
    );
  }

  static Future<Map<String, dynamic>> getDetail({
    required int materiId,
    required int babId,
  }) async {
    return ApiService.get('/dashboard/materi/$materiId/bab/$babId');
  }
}
