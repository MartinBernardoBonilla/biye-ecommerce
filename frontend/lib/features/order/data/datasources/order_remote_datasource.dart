// lib/features/order/data/datasources/order_remote_datasource.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:biye/core/utils/auth_storage.dart';

class OrderRemoteDataSource {
  final String baseUrl;
  final http.Client client;

  OrderRemoteDataSource({
    required this.baseUrl,
    required this.client,
  });

  Future<Map<String, dynamic>> getMyOrders() async {
    final token = await AuthStorage.getToken();

    final response = await client.get(
      Uri.parse('$baseUrl/api/v1/orders/myorders'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error cargando órdenes');
    }
  }

  Future<Map<String, dynamic>> getOrderById(String orderId) async {
    final token = await AuthStorage.getToken();

    final response = await client.get(
      Uri.parse('$baseUrl/api/v1/orders/$orderId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error cargando orden');
    }
  }

  Future<Map<String, dynamic>> createOrder(
      Map<String, dynamic> orderData) async {
    final token = await AuthStorage.getToken();

    final response = await client.post(
      Uri.parse('$baseUrl/api/v1/orders'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(orderData),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error creando orden');
    }
  }
}
