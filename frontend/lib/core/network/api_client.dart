import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants/app_constants.dart';

class ApiClient {
  final http.Client _client = http.Client();
  final String _baseUrl = AppConstants.apiBaseUrl;

  // 1. Variable para guardar el token en memoria
  String? _authToken;

  // 2. Método para que el AuthBloc le pase el token al loguearse
  void updateToken(String? token) {
    _authToken = token;

    if (_authToken != null) {
      print('🟢 AUTH HEADER SENT: Bearer $_authToken');
    }
  }

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };

    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
      print('🟢 API CLIENT → ENVIANDO TOKEN: $_authToken');
    } else {
      print('🔴 API CLIENT → NO HAY TOKEN');
    }

    return headers;
  }

  // Método GET (¡TE FALTA ESTO!)
  Future<Map<String, dynamic>> get(String path) async {
    try {
      final uri = Uri.parse('$_baseUrl/$path');
      print('🌐 GET: $uri');

      final response = await _client
          .get(
            uri,
            headers: _headers,
          )
          .timeout(const Duration(seconds: 30));

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Failed to load data. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      print('❌ GET Error: $e');
      rethrow;
    }
  }

  // Método POST (mejorado)
  Future<Map<String, dynamic>> post(String path, dynamic body) async {
    try {
      final uri = Uri.parse('$_baseUrl/$path');
      print('🌐 POST: $uri');

      final response = await _client
          .post(
            uri,
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Failed to post data. Status: ${response.statusCode}, Body: ${response.body}',
        );
      }
    } catch (e) {
      print('❌ POST Error: $e');
      rethrow;
    }
  }

  // Métodos adicionales que necesitarás
  Future<Map<String, dynamic>> put(String path, dynamic body) async {
    final uri = Uri.parse('$_baseUrl/$path');
    final response = await _client.put(
      uri,
      headers: _headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update data: ${response.statusCode}');
    }
  }

  Future<void> delete(String path) async {
    final uri = Uri.parse('$_baseUrl/$path');
    final response = await _client.delete(
      uri,
      headers: _headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete: ${response.statusCode}');
    }
  }
}
