import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../utils/api_config.dart';

class RakBukuService {
  /// Add a materi to the user's rak buku (bookshelf)
  static Future<Map<String, dynamic>> addToRak(int materiId) async {
    try {
      final res = await ApiService.post(ApiConfig.rakBukuEndpoint, {'materi_id': materiId});
      if (kDebugMode) debugPrint('[RakBukuService] addToRak -> $res');
      return res;
    } catch (e) {
      if (kDebugMode) debugPrint('[RakBukuService] error -> $e');
      return {'error': e.toString()};
    }
  }

  /// Remove materi from rak buku
  static Future<Map<String, dynamic>> removeFromRak(int materiId) async {
    try {
      final endpoint = '${ApiConfig.rakBukuEndpoint}/$materiId';
      final res = await ApiService.delete(endpoint);
      if (kDebugMode) debugPrint('[RakBukuService] removeFromRak -> $res');
      return res;
    } catch (e) {
      if (kDebugMode) debugPrint('[RakBukuService] error -> $e');
      return {'error': e.toString()};
    }
  }

  /// Check whether materi is already in rak buku
  static Future<Map<String, dynamic>> status(int materiId) async {
    try {
      final endpoint = '${ApiConfig.rakBukuEndpoint}/$materiId/status';
      final res = await ApiService.get(endpoint);
      if (kDebugMode) debugPrint('[RakBukuService] status -> $res');
      return res;
    } catch (e) {
      if (kDebugMode) debugPrint('[RakBukuService] error -> $e');
      return {'error': e.toString()};
    }
  }

  /// List rak buku entries for current authenticated user (paginated)
  static Future<Map<String, dynamic>> list({int page = 1, int perPage = 20}) async {
    try {
      final endpoint = '${ApiConfig.rakBukuEndpoint}?page=$page&per_page=$perPage';
      final res = await ApiService.get(endpoint);
      if (kDebugMode) debugPrint('[RakBukuService] list -> ${res}');
      return res;
    } catch (e) {
      if (kDebugMode) debugPrint('[RakBukuService] error -> $e');
      return {'error': e.toString()};
    }
  }
}
