import '../utils/api_config.dart';
import 'api_service.dart';

class MateriService {
  static Future<Map<String, dynamic>> getAll({int? page, int? perPage, int? levelId}) async {
    final params = <String, String>{};
    if (page != null) {
      params['page'] = page.toString();
    }
    if (perPage != null) {
      params['per_page'] = perPage.toString();
    }
    if (levelId != null) {
      params['level_id'] = levelId.toString();
    }
    final endpoint = _withQuery(ApiConfig.materiEndpoint, params);
    return ApiService.get(endpoint);
  }

  static Future<Map<String, dynamic>> getSingle(int id) async {
    return ApiService.get('${ApiConfig.materiEndpoint}/$id');
  }

  static String _withQuery(String endpoint, Map<String, String> params) {
    if (params.isEmpty) {
      return endpoint;
    }
    final query = Uri(queryParameters: params).query;
    return '$endpoint?$query';
  }
}
