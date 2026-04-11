import '../utils/api_config.dart';
import 'api_service.dart';

class LevelService {
  static Future<Map<String, dynamic>> getAll({int? page, int? perPage}) async {
    final params = <String, String>{};
    if (page != null) {
      params['page'] = page.toString();
    }
    if (perPage != null) {
      params['per_page'] = perPage.toString();
    }
    final endpoint = _withQuery(ApiConfig.levelEndpoint, params);
    return ApiService.get(endpoint);
  }

  static Future<Map<String, dynamic>> getSingle(int id) async {
    return ApiService.get('${ApiConfig.levelEndpoint}/$id');
  }

  static Future<Map<String, dynamic>> createLevel({
    required String nama,
    String? deskripsi,
    bool? statusAktif,
  }) async {
    final data = <String, String>{
      'nama': nama,
    };
    if (deskripsi != null) {
      data['deskripsi'] = deskripsi;
    }
    if (statusAktif != null) {
      data['status_aktif'] = statusAktif ? '1' : '0';
    }
    return ApiService.postForm(ApiConfig.levelEndpoint, data);
  }

  static String _withQuery(String endpoint, Map<String, String> params) {
    if (params.isEmpty) {
      return endpoint;
    }
    final query = Uri(queryParameters: params).query;
    return '$endpoint?$query';
  }
}
