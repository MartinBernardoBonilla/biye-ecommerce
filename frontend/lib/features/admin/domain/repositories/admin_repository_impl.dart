// lib/features/admin/data/repositories/admin_repository_impl.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:biye/features/admin/domain/repositories/admin_repository.dart';
import 'package:biye/features/admin/domain/entities/admin_stats.dart';
import 'package:biye/features/admin/domain/entities/admin_order.dart';
import 'package:biye/core/utils/auth_storage.dart';

class AdminRepositoryImpl implements AdminRepository {
  final String baseUrl;
  final http.Client client;

  AdminRepositoryImpl({
    required this.baseUrl,
    required this.client,
  });

  @override
  Future<AdminStats> getDashboardStats() async {
    final token = await AuthStorage.getToken();
    debugPrint(
        '🔑 [ADMIN] Token para /stats: ${token != null ? token.substring(0, 15) : 'null'}...');

    final response = await client.get(
      Uri.parse('$baseUrl/api/v1/admin/stats'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    debugPrint('📥 [ADMIN] Status /stats: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      debugPrint('✅ [ADMIN] Stats cargados correctamente');
      debugPrint('📦 [ADMIN] Data completa: $data');

      // ✅ Pasar todo el objeto, el factory ya extraerá 'data'
      return AdminStats.fromJson(data);
    } else {
      debugPrint('❌ [ADMIN] Error cargando stats: ${response.body}');
      throw Exception('Error cargando estadísticas');
    }
  }

  @override
  Future<List<AdminOrder>> getRecentOrders({int limit = 5}) async {
    final token = await AuthStorage.getToken();
    debugPrint(
        '🔑 [ADMIN] Token para /recent: ${token != null ? token.substring(0, 15) : 'null'}...');

    final response = await client.get(
      Uri.parse('$baseUrl/api/v1/admin/orders/recent?limit=$limit'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    debugPrint('📥 [ADMIN] Status /recent: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      debugPrint('📦 [ADMIN] Tipo de data: ${data.runtimeType}');

      // ✅ MANEJO DE AMBOS FORMATOS
      if (data is List) {
        return data.map((e) => AdminOrder.fromJson(e)).toList();
      } else if (data is Map && data.containsKey('data')) {
        final List ordersData = data['data'];
        return ordersData.map((e) => AdminOrder.fromJson(e)).toList();
      } else {
        debugPrint('❌ [ADMIN] Formato inesperado: $data');
        return [];
      }
    } else {
      return [];
    }
  }

  @override
  Future<List<AdminOrder>> getOrders({int page = 1, int limit = 20}) async {
    final token = await AuthStorage.getToken();
    debugPrint(
        '🔑 [ADMIN] Token para /orders: ${token != null ? token.substring(0, 15) : 'null'}...');

    final response = await client.get(
      Uri.parse('$baseUrl/api/v1/admin/orders?page=$page&limit=$limit'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    debugPrint('📥 [ADMIN] Status /orders: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data is List) {
        return data.map((e) => AdminOrder.fromJson(e)).toList();
      } else if (data is Map && data.containsKey('data')) {
        final List ordersData = data['data'];
        return ordersData.map((e) => AdminOrder.fromJson(e)).toList();
      } else {
        throw Exception('Formato de respuesta inesperado');
      }
    } else {
      throw Exception('Error cargando órdenes');
    }
  }

  @override
  Future<List<dynamic>> getUsers({int page = 1, int limit = 20}) async {
    final token = await AuthStorage.getToken();
    debugPrint(
        '🔑 [ADMIN] Token para /users: ${token != null ? token.substring(0, 15) : 'null'}...');

    final response = await client.get(
      Uri.parse('$baseUrl/api/v1/admin/users?page=$page&limit=$limit'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    debugPrint('📥 [ADMIN] Status /users: ${response.statusCode}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      debugPrint('📦 [ADMIN] Respuesta COMPLETA: $jsonResponse');

      // ✅ CORRECCIÓN: Los usuarios están en jsonResponse['data']
      if (jsonResponse.containsKey('data') && jsonResponse['data'] is List) {
        final List<dynamic> users = jsonResponse['data'];
        debugPrint('✅ [ADMIN] Usuarios EXTRAÍDOS: ${users.length}');
        debugPrint(
            '👤 [ADMIN] Primer usuario: ${users.isNotEmpty ? users.first : 'Ninguno'}');
        return users;
      } else {
        debugPrint('❌ [ADMIN] FORMATO INCORRECTO. Keys: ${jsonResponse.keys}');
        debugPrint('❌ [ADMIN] Valor de "data": ${jsonResponse['data']}');
        return [];
      }
    } else {
      debugPrint('❌ [ADMIN] Error HTTP: ${response.statusCode}');
      throw Exception('Error cargando usuarios');
    }
  }
}
