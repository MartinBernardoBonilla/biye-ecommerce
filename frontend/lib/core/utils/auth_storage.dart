// lib/core/utils/auth_storage.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  // Usar secure storage en móvil, shared_preferences en web
  static final _secureStorage = FlutterSecureStorage();

  // Keys
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userRoleKey = 'user_role';

  // Detectar plataforma
  static bool get _isWeb => kIsWeb;

  // Obtener instancia de SharedPreferences (solo para web)
  static Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  // Guardar token
  static Future<void> saveToken(String token) async {
    debugPrint(
        '💾 [AUTH] Guardando token en ${_isWeb ? 'Web' : 'Móvil'}: ${token.substring(0, 15)}...');

    if (_isWeb) {
      final prefs = await _getPrefs();
      await prefs.setString(_tokenKey, token);
    } else {
      await _secureStorage.write(key: _tokenKey, value: token);
    }

    // Verificar que se guardó
    final saved = await getToken();
    debugPrint(
        '✅ [AUTH] Token guardado correctamente: ${saved != null ? saved.substring(0, 15) : 'null'}...');
  }

  // Obtener token
  static Future<String?> getToken() async {
    String? token;

    if (_isWeb) {
      final prefs = await _getPrefs();
      token = prefs.getString(_tokenKey);
    } else {
      token = await _secureStorage.read(key: _tokenKey);
    }

    debugPrint(
        '🔍 [AUTH] Recuperando token de ${_isWeb ? 'Web' : 'Móvil'}: ${token != null ? token.substring(0, 15) : 'null'}...');
    return token;
  }

  // Guardar datos del usuario
  static Future<void> saveUserData({
    required String userId,
    required String email,
    required String role,
  }) async {
    if (_isWeb) {
      final prefs = await _getPrefs();
      await prefs.setString(_userIdKey, userId);
      await prefs.setString(_userEmailKey, email);
      await prefs.setString(_userRoleKey, role);
    } else {
      await _secureStorage.write(key: _userIdKey, value: userId);
      await _secureStorage.write(key: _userEmailKey, value: email);
      await _secureStorage.write(key: _userRoleKey, value: role);
    }
    debugPrint(
        '👤 [AUTH] Datos de usuario guardados en ${_isWeb ? 'Web' : 'Móvil'}');
  }

  // Obtener datos del usuario
  static Future<Map<String, String?>> getUserData() async {
    if (_isWeb) {
      final prefs = await _getPrefs();
      return {
        'userId': prefs.getString(_userIdKey),
        'email': prefs.getString(_userEmailKey),
        'role': prefs.getString(_userRoleKey),
      };
    } else {
      return {
        'userId': await _secureStorage.read(key: _userIdKey),
        'email': await _secureStorage.read(key: _userEmailKey),
        'role': await _secureStorage.read(key: _userRoleKey),
      };
    }
  }

  // Verificar si hay sesión activa
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Verificar si es admin
  static Future<bool> isAdmin() async {
    if (_isWeb) {
      final prefs = await _getPrefs();
      return prefs.getString(_userRoleKey) == 'admin';
    } else {
      final role = await _secureStorage.read(key: _userRoleKey);
      return role == 'admin';
    }
  }

  // Limpiar todo (logout)
  static Future<void> clearAll() async {
    if (_isWeb) {
      final prefs = await _getPrefs();
      await prefs.clear();
    } else {
      await _secureStorage.deleteAll();
    }
    debugPrint(
        '🧹 [AUTH] Todos los datos eliminados de ${_isWeb ? 'Web' : 'Móvil'}');
  }

  // Eliminar token específico (logout suave)
  static Future<void> deleteToken() async {
    if (_isWeb) {
      final prefs = await _getPrefs();
      await prefs.remove(_tokenKey);
    } else {
      await _secureStorage.delete(key: _tokenKey);
    }
    debugPrint('🗑️ [AUTH] Token eliminado de ${_isWeb ? 'Web' : 'Móvil'}');
  }
}
