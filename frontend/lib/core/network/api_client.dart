import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../constants/app_constants.dart';
import '../utils/auth_storage.dart';

class ApiClient {
  final http.Client _client = http.Client();
  final String _baseUrl = AppConstants.apiBaseUrl;

  String? _token;

  // 🔥 LOCK para evitar múltiples refresh simultáneos
  Future<String?>? _refreshFuture;

  ApiClient() {
    _loadToken();
  }

  // ======================
  // TOKEN MANAGEMENT
  // ======================

  Future<void> _loadToken() async {
    _token = await AuthStorage.getToken();
  }

  Future<void> setToken(String token) async {
    _token = token;
    await AuthStorage.saveToken(token);
  }

  Future<void> clearToken() async {
    _token = null;
    await AuthStorage.deleteToken();
  }

  // ======================
  // HEADERS
  // ======================

  Future<Map<String, String>> _getHeaders() async {
    await _loadToken();

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  // ======================
  // HTTP METHODS
  // ======================

  Future<Map<String, dynamic>> get(String path) async {
    final uri = Uri.parse('$_baseUrl/$path');

    final headers = await _getHeaders();
    final response = await _client.get(uri, headers: headers);

    return await _handleResponse(response, path, 'GET', null);
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$_baseUrl/$path');

    final headers = await _getHeaders();
    final response = await _client.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    return await _handleResponse(response, path, 'POST', body);
  }

  Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$_baseUrl/$path');

    final headers = await _getHeaders();
    final response = await _client.put(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    return await _handleResponse(response, path, 'PUT', body);
  }

  Future<Map<String, dynamic>> delete(String path) async {
    final uri = Uri.parse('$_baseUrl/$path');

    final headers = await _getHeaders();
    final response = await _client.delete(uri, headers: headers);

    return await _handleResponse(response, path, 'DELETE', null);
  }

  // ======================
  // RESPONSE HANDLER (PRO)
  // ======================

  Future<Map<String, dynamic>> _handleResponse(
    http.Response response,
    String path,
    String method,
    Map<String, dynamic>? body,
  ) async {
    final data = jsonDecode(response.body);

    // ✅ OK
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    // 🔒 TOKEN EXPIRADO → REFRESH
    if (response.statusCode == 401) {
      debugPrint('🔒 Token expirado → intentando refresh');

      final newToken = await _refreshToken();

      if (newToken != null) {
        debugPrint('🔁 Reintentando request...');
        return await _retryRequest(path, method, body);
      } else {
        debugPrint('❌ Refresh falló → logout');
        await AuthStorage.clearAll();
        throw Exception('SESSION_EXPIRED');
      }
    }

    final errorMsg = data['message'] ?? 'Error inesperado';
    throw Exception(errorMsg);
  }

  // ======================
  // REFRESH TOKEN 🔥
  // ======================

  Future<String?> _refreshToken() async {
    // 🔥 Evita múltiples llamadas simultáneas
    if (_refreshFuture != null) return _refreshFuture;

    _refreshFuture = _performRefresh();
    final token = await _refreshFuture;
    _refreshFuture = null;

    return token;
  }

  Future<String?> _performRefresh() async {
    try {
      final refreshToken = await AuthStorage.getRefreshToken();

      if (refreshToken == null) {
        debugPrint('❌ No hay refresh token');
        return null;
      }

      final uri = Uri.parse('$_baseUrl/auth/refresh');

      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final newAccessToken = data['data']?['accessToken'];

        if (newAccessToken != null) {
          await setToken(newAccessToken);
          debugPrint('✅ Token refrescado correctamente');
          return newAccessToken;
        }
      }

      return null;
    } catch (e) {
      debugPrint('❌ Error en refresh: $e');
      return null;
    }
  }

  // ======================
  // RETRY REQUEST 🔁
  // ======================

  Future<Map<String, dynamic>> _retryRequest(
    String path,
    String method,
    Map<String, dynamic>? body,
  ) async {
    final uri = Uri.parse('$_baseUrl/$path');
    final headers = await _getHeaders();

    late http.Response response;

    switch (method) {
      case 'POST':
        response = await _client.post(
          uri,
          headers: headers,
          body: jsonEncode(body),
        );
        break;

      case 'PUT':
        response = await _client.put(
          uri,
          headers: headers,
          body: jsonEncode(body),
        );
        break;

      case 'DELETE':
        response = await _client.delete(uri, headers: headers);
        break;

      default:
        response = await _client.get(uri, headers: headers);
    }

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    throw Exception(data['message'] ?? 'Error en retry');
  }

  // ======================
  // CLEANUP
  // ======================

  void dispose() {
    _client.close();
  }
}
