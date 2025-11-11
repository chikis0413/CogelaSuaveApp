import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:cogela_suave/Config/api.dart';

class ApiService {
  ApiService._();

  static final client = http.Client();

  static Uri _buildUri(String path) {
    final base = ApiConfig.baseUrl;
    final normalized = base.endsWith('/') ? base : '$base/';
    return Uri.parse('$normalized${path.startsWith('/') ? path.substring(1) : path}');
  }

  static Future<http.Response> get(String path, {Map<String, String>? headers}) async {
    final uri = _buildUri(path);
    final allHeaders = {...ApiConfig.defaultHeaders, if (headers != null) ...headers};
    final resp = await client.get(uri, headers: allHeaders).timeout(ApiConfig.requestTimeout);
    return resp;
  }

  static Future<http.Response> post(String path, Object? body, {Map<String, String>? headers}) async {
    final uri = _buildUri(path);
    final allHeaders = {...ApiConfig.defaultHeaders, if (headers != null) ...headers};
    final payload = body == null ? null : jsonEncode(body);
    final resp = await client.post(uri, headers: allHeaders, body: payload).timeout(ApiConfig.requestTimeout);
    return resp;
  }

  static Future<http.Response> put(String path, Object? body, {Map<String, String>? headers}) async {
    final uri = _buildUri(path);
    final allHeaders = {...ApiConfig.defaultHeaders, if (headers != null) ...headers};
    final payload = body == null ? null : jsonEncode(body);
    final resp = await client.put(uri, headers: allHeaders, body: payload).timeout(ApiConfig.requestTimeout);
    return resp;
  }

  static Future<http.Response> delete(String path, {Map<String, String>? headers}) async {
    final uri = _buildUri(path);
    final allHeaders = {...ApiConfig.defaultHeaders, if (headers != null) ...headers};
    final resp = await client.delete(uri, headers: allHeaders).timeout(ApiConfig.requestTimeout);
    return resp;
  }

  // Convenience example: login (adjust endpoint as your API expects)
  static Future<Map<String, dynamic>?> login(String username, String password) async {
    final resp = await post('auth/login', {'username': username, 'password': password});
    if (resp.statusCode == 200) {
      try {
        return jsonDecode(resp.body) as Map<String, dynamic>;
      } catch (e) {
        return {'error': 'Invalid JSON response'};
      }
    }
    return {'error': 'HTTP ${resp.statusCode}', 'body': resp.body};
  }
}
