// lib/core/network/api_client.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';
import '../utils/auth_storage.dart';

import 'package:biye/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:biye/features/auth/presentation/bloc/auth_event.dart';

class ApiClient {
  final http.Client _client = http.Client();
  final String _baseUrl = AppConstants.apiBaseUrl;

  String? _token;
  AuthBloc? authBloc;

  // 🔥 CONTROL DE REFRESH
  bool _isRefreshing = false;
  Completer<void>? _refreshCompleter;

  // ======================
  // TOKEN
  // ======================

  Future<void> setToken(String? token) async {
    _token = token;

    if (token != null) {
      await AuthStorage.saveToken(token);
    } else {
      await AuthStorage.deleteToken();
    }
  }

  Future<void> clearToken() async {
    _token = null;
    await AuthStorage.deleteToken();
  }

  // ======================
  // HEADERS
  // ======================

  Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    _token ??= await AuthStorage.getToken();

    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  // ======================
  // HTTP METHODS
  // ======================

  Future<Map<String, dynamic>> get(String path) async {
    return _request(() => _client.get(
          Uri.parse('$_baseUrl/$path'),
          headers: await _getHeaders(),
        ));
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    return _request(() => _client.post(
          Uri.parse('$_baseUrl/$path'),
          headers: await _getHeaders(),
          body: jsonEncode(body),
        ));
  }

  Future<Map<String, dynamic>> _request(
    Future<http.Response> Function() requestFn,
  ) async {
    final response = await requestFn();

    // ✅ OK
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }

    // 🔒 401 → intentar refresh
    if (response.statusCode == 401) {
      debugPrint('🔒 401 detectado → intentando refresh');

      final refreshed = await _handleRefreshToken();

      if (refreshed) {
        debugPrint('🔁 Reintentando request...');
        final retryResponse = await requestFn();

        if (retryResponse.statusCode >= 200 &&
            retryResponse.statusCode < 300) {
          return jsonDecode(retryResponse.body);
        }
      }

      // ❌ FALLÓ REFRESH → LOGOUT
      debugPrint('❌ Refresh falló → logout');

      await AuthStorage.clearAll();
      authBloc?.add(AuthLogoutRequested());

      throw Exception('SESSION_EXPIRED');
    }

    // ❌ ERROR NORMAL
    final data = jsonDecode(response.body);
    final errorMsg = data['message'] ?? 'Error inesperado';

    throw Exception(errorMsg);
  }

  // ======================
  // 🔥 REFRESH TOKEN LOGIC
  // ======================

  Future<bool> _handleRefreshToken() async {
    // 🧠 Si ya se está refrescando → esperar
    if (_isRefreshing) {
      debugPrint('⏳ Esperando refresh en progreso...');
      await _refreshCompleter?.future;
      return _token != null;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer();

    try {
      final refreshToken = await AuthStorage.getRefreshToken();

      if (refreshToken == null) {
        debugPrint('❌ No hay refresh token');
        return false;
      }

      final response = await _client.post(
        Uri.parse('$_baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final newToken = data['data']['accessToken'];

        if (newToken == null) return false;

        await setToken(newToken);

        debugPrint('✅ Token refrescado correctamente');

        _refreshCompleter?.complete();

        return true;
      }

      return false;
    } catch (e) {
      debugPrint('❌ Error en refresh: $e');
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  void dispose() {
    _client.close();
  }
}