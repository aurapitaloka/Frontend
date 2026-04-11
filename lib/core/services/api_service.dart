import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';
import 'token_storage.dart';

class ApiService {
  // Base URL - sesuaikan dengan URL backend Anda di lib/core/utils/api_config.dart
  static String get baseUrl => ApiConfig.baseUrl;
  static final Map<String, String> _cookies = {};

  // Headers
  static Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (_cookies.isNotEmpty) 'Cookie': _cookieHeader(),
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, String>> _formHeaders() async {
    final token = await TokenStorage.getToken();
    return {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',
      if (_cookies.isNotEmpty) 'Cookie': _cookieHeader(),
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // GET Request
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final headers = await _headers();
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );
      _updateCookies(response.headers);
      return _handleResponse(response);
    } catch (e) {
      return {'error': 'Network error: $e'};
    }
  }

  // POST Request
  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final headers = await _headers();
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      );
      _updateCookies(response.headers);
      return _handleResponse(response);
    } catch (e) {
      return {'error': 'Network error: $e'};
    }
  }

  // POST Form URL Encoded
  static Future<Map<String, dynamic>> postForm(
    String endpoint,
    Map<String, String> data,
  ) async {
    try {
      final headers = await _formHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: data,
      );
      _updateCookies(response.headers);
      return _handleResponse(response);
    } catch (e) {
      return {'error': 'Network error: $e'};
    }
  }

  // PUT Request
  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final headers = await _headers();
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(data),
      );
      _updateCookies(response.headers);
      return _handleResponse(response);
    } catch (e) {
      return {'error': 'Network error: $e'};
    }
  }

  // DELETE Request
  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final headers = await _headers();
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );
      _updateCookies(response.headers);
      return _handleResponse(response);
    } catch (e) {
      return {'error': 'Network error: $e'};
    }
  }

  // Multipart request (file upload / form-data)
  static Future<Map<String, dynamic>> multipartRequest(
    String method,
    String endpoint, {
    Map<String, String>? fields,
    Map<String, File>? files,
  }) async {
    try {
      final token = await TokenStorage.getToken();
      final uri = Uri.parse('$baseUrl$endpoint');
      final request = http.MultipartRequest(method, uri);
      if (fields != null && fields.isNotEmpty) {
        request.fields.addAll(fields);
      }
      if (files != null && files.isNotEmpty) {
        for (final entry in files.entries) {
          final multipartFile = await http.MultipartFile.fromPath(entry.key, entry.value.path);
          request.files.add(multipartFile);
        }
      }

      final headers = <String, String>{'Accept': 'application/json'};
      if (_cookies.isNotEmpty) headers['Cookie'] = _cookieHeader();
      if (token != null && token.isNotEmpty) headers['Authorization'] = 'Bearer $token';
      request.headers.addAll(headers);

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      _updateCookies(response.headers);
      return _handleResponse(response);
    } catch (e) {
      return {'error': 'Network error: $e'};
    }
  }

  static void _updateCookies(Map<String, String> headers) {
    final rawCookie = headers['set-cookie'];
    if (rawCookie == null || rawCookie.isEmpty) return;
    final parts = _splitSetCookie(rawCookie);
    for (final part in parts) {
      final segments = part.split(';');
      if (segments.isEmpty) continue;
      final pair = segments.first.trim();
      final eqIndex = pair.indexOf('=');
      if (eqIndex <= 0) continue;
      final name = pair.substring(0, eqIndex);
      final value = pair.substring(eqIndex + 1);
      _cookies[name] = value;
    }
  }

  static List<String> _splitSetCookie(String header) {
    final parts = <String>[];
    var start = 0;
    var inExpires = false;
    for (var i = 0; i < header.length; i++) {
      final char = header[i];
      final lower =
          i + 8 <= header.length ? header.substring(i, i + 8).toLowerCase() : '';
      if (lower == 'expires=') {
        inExpires = true;
      } else if (inExpires && char == ';') {
        inExpires = false;
      } else if (char == ',' && !inExpires) {
        parts.add(header.substring(start, i).trim());
        start = i + 1;
      }
    }
    if (start < header.length) {
      parts.add(header.substring(start).trim());
    }
    return parts;
  }

  static String _cookieHeader() {
    return _cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
  }

  static String? cookieHeader() {
    if (_cookies.isEmpty) return null;
    return _cookieHeader();
  }

  // Handle Response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return {...data, '_status_code': response.statusCode};
      } catch (e) {
        return {
          'success': true,
          'message': response.body,
          '_status_code': response.statusCode,
        };
      }
    } else {
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return {...data, '_status_code': response.statusCode};
      } catch (e) {
        return {
          'error': 'Error ${response.statusCode}: ${response.body}',
          '_status_code': response.statusCode,
        };
      }
    }
  }
}
