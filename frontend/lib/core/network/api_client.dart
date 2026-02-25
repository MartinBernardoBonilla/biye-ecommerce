import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../constants/app_constants.dart';
import '../utils/auth_storage.dart'; // 👈 IMPORTAR AUTHSTORAGE

class ApiClient {
  final http.Client _client = http.Client();
  final String _baseUrl = AppConstants.apiBaseUrl;

  void updateToken(String token) {
    setToken(token);
  }

  String? _token;

  // ======================
  // TOKEN MANAGEMENT
  // ======================
  void setToken(String token) {
    _token = token;
    debugPrint('🟢 API CLIENT → Token seteado en memoria');

    // ✅ SINCRONIZAR CON AUTHSTORAGE
    AuthStorage.saveToken(token);
  }

  void clearToken() {
    _token = null;
    AuthStorage.deleteToken(); // ✅ TAMBIÉN LIMPIAR AUTHSTORAGE
    debugPrint('🟡 API CLIENT → Token limpiado');
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
      debugPrint('🟢 API CLIENT → Authorization enviada');
    } else {
      debugPrint('🔴 API CLIENT → NO HAY TOKEN');
    }

    return headers;
  }

  // ======================
  // HTTP METHODS
  // ======================
  Future<Map<String, dynamic>> get(String path) async {
    final uri = Uri.parse('$_baseUrl/$path');
    debugPrint('🌐 GET $uri');

    final response = await _client.get(uri, headers: _headers);

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$_baseUrl/$path');
    debugPrint('🌐 POST $uri');

    final response = await _client.post(
      uri,
      headers: _headers,
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$_baseUrl/$path');

    final response = await _client.put(
      uri,
      headers: _headers,
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  Future<void> delete(String path) async {
    final uri = Uri.parse('$_baseUrl/$path');

    final response = await _client.delete(uri, headers: _headers);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('DELETE failed: ${response.body}');
    }
  }

  // ======================
  // RESPONSE HANDLER
  // ======================
  Map<String, dynamic> _handleResponse(http.Response response) {
    debugPrint('📥 Status: ${response.statusCode}');

    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(
        data['message'] ?? 'Error inesperado',
      );
    }
  }
}
