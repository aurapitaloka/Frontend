import '../utils/api_config.dart';
import 'api_service.dart';

class SesiBacaService {
  static Future<Map<String, dynamic>> getLast(int materiId) async {
    final endpoint = '/dashboard/sesi-baca/$materiId/last';
    return ApiService.get(endpoint);
  }

  static Future<Map<String, dynamic>> upsert(Map<String, dynamic> data) async {
    final endpoint = '/dashboard/sesi-baca/upsert';
    return ApiService.post(endpoint, data);
  }

  static Future<Map<String, dynamic>> list({int? page, int? perPage}) async {
    final params = <String, String>{};
    if (page != null) params['page'] = page.toString();
    if (perPage != null) params['per_page'] = perPage.toString();
    final query = params.isNotEmpty ? '?'+Uri(queryParameters: params).query : '';
    return ApiService.get('/dashboard/sesi-baca$query');
  }
}
