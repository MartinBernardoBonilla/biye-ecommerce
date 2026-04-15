// lib/core/network/api_client.dart

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../constants/app_constants.dart';
import '../utils/auth_storage.dart';

class ApiClient {
  final http.Client _client = http.Client();
  final String _baseUrl = AppConstants.apiBaseUrl;
  String? _token;

  ApiClient() {
    _loadToken();
  }

  // ======================
  // TOKEN MANAGEMENT
  // ======================

  Future<void> _loadToken() async {
    _token = await AuthStorage.getToken();
    if (_token != null) {
      debugPrint('🟢 API CLIENT → Token cargado de storage');
    }
  }

  Future<void> setToken(String token) async {
    _token = token;
    await AuthStorage.saveToken(token);
    debugPrint('🟢 API CLIENT → Token seteado en memoria y storage');
  }

  Future<void> clearToken() async {
    _token = null;
    await AuthStorage.deleteToken();
    debugPrint('🟡 API CLIENT → Token limpiado');
  }

  Future<Map<String, String>> _getHeaders() async {
    await _loadToken();

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
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
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🌐 GET $uri');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    final headers = await _getHeaders();
    final response = await _client.get(uri, headers: headers);

    return _handleResponse(response, path);
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$_baseUrl/$path');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🌐 POST $uri');
    debugPrint('📦 BODY: ${jsonEncode(body)}');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    final headers = await _getHeaders();
    final response = await _client.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    return _handleResponse(response, path);
  }

  Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$_baseUrl/$path');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🌐 PUT $uri');
    debugPrint('📦 BODY: ${jsonEncode(body)}');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    final headers = await _getHeaders();
    final response = await _client.put(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    return _handleResponse(response, path);
  }

  Future<Map<String, dynamic>> delete(String path) async {
    final uri = Uri.parse('$_baseUrl/$path');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('🌐 DELETE $uri');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    final headers = await _getHeaders();
    final response = await _client.delete(uri, headers: headers);

    return _handleResponse(response, path);
  }

  // ======================
  // RESPONSE HANDLER
  // ======================

  Map<String, dynamic> _handleResponse(http.Response response, String path) {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('📥 RESPONSE for: $path');
    debugPrint('📊 Status: ${response.statusCode}');

    final data = jsonDecode(response.body);
    debugPrint('📦 DATA: ${_prettyPrint(data)}');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      final errorMsg = data['message'] ?? 'Error inesperado';
      debugPrint('❌ ERROR: $errorMsg');
      throw Exception(errorMsg);
    }
  }

  // ======================
  // HELPER: Pretty Print JSON
  // ======================

  String _prettyPrint(Map<String, dynamic> json) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(json);
  }

  // ======================
  // CLEANUP
  // ======================

  void dispose() {
    _client.close();
  }
}
