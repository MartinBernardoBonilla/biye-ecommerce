// lib/features/order/data/repositories/order_repository_impl.dart

import 'package:biye/core/network/api_client.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;
  final ApiClient apiClient;

  OrderRepositoryImpl({
    required this.remoteDataSource,
    required this.apiClient,
  });

  @override
  Future<Order?> createOrder(Order order) async {
    try {
      final response = await apiClient.post('orders', order.toJson());

      // Si el backend te devuelve la orden directa o dentro de data/order
      if (response != null) {
        final orderData = response['data'] ?? response['order'] ?? response;
        return Order.fromJson(orderData as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('❌ Error creando orden: $e');
      return null;
    }
  }

  @override
  Future<Order?> getOrder(String id) async {
    try {
      final response = await apiClient.get('orders/$id');

      if (response != null && response['success'] == true) {
        // 🎯 SOLUCIÓN: Buscamos en 'data', si no está probamos con 'order' o el body entero
        final orderData = response['data'] ?? response['order'] ?? response;

        if (orderData != null) {
          return Order.fromJson(orderData as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      print('❌ Error obteniendo orden: $e');
      return null;
    }
  }

  @override
  Future<List<Order>> getUserOrders() async {
    try {
      final response = await apiClient.get('orders');

      if (response != null && response['success'] == true) {
        // El listado de mis órdenes suele venir en 'data' o 'orders'
        final List<dynamic>? ordersJson =
            response['data'] ?? response['orders'];

        if (ordersJson != null) {
          return ordersJson
              .map((json) => Order.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('❌ Error obteniendo órdenes: $e');
      return [];
    }
  }
}
