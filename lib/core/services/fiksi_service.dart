import '../utils/api_config.dart';
import 'api_service.dart';

class FiksiService {
  static Future<Map<String, dynamic>> getAll({int? page, int? perPage}) async {
    final params = <String, String>{};
    if (page != null) {
      params['page'] = page.toString();
    }
    if (perPage != null) {
      params['per_page'] = perPage.toString();
    }
    final endpoint = _withQuery(ApiConfig.fiksiEndpoint, params);
    return ApiService.get(endpoint);
  }

  static Future<Map<String, dynamic>> getSingle(int id) async {
    return ApiService.get('${ApiConfig.fiksiEndpoint}/$id');
  }

  static String _withQuery(String endpoint, Map<String, String> params) {
    if (params.isEmpty) {
      return endpoint;
    }
    final query = Uri(queryParameters: params).query;
    return '$endpoint?$query';
  }
}
