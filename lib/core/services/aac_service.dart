import 'api_service.dart';

class AacService {
  static Future<Map<String, dynamic>> getAll({
    int page = 1,
    int perPage = 50,
  }) async {
    final endpoints = [
      '/dashboard/aac?page=$page&per_page=$perPage',
      '/dashboard-siswa/aac?page=$page&per_page=$perPage',
      '/aac?page=$page&per_page=$perPage',
    ];
    return _tryEndpoints(endpoints);
  }

  static Future<Map<String, dynamic>> getSingle(int id) async {
    final endpoints = [
      '/dashboard/aac/$id',
      '/dashboard-siswa/aac/$id',
      '/aac/$id',
    ];
    return _tryEndpoints(endpoints);
  }

  static Future<Map<String, dynamic>> _tryEndpoints(
    List<String> endpoints,
  ) async {
    Map<String, dynamic> lastRes = {};
    for (final endpoint in endpoints) {
      final res = await ApiService.get(endpoint);
      lastRes = res;
      final status = res['_status_code'] as int?;
      if (status != 404) return res;
    }
    return lastRes;
  }
}
