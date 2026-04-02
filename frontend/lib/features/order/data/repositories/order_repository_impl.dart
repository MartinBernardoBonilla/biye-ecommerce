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

      if (response['success'] == true) {
        return Order.fromJson(response['order']);
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

      if (response['success'] == true) {
        return Order.fromJson(response['order']);
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

      if (response['success'] == true) {
        final List<dynamic> ordersJson = response['orders'];
        return ordersJson.map((json) => Order.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Error obteniendo órdenes: $e');
      return [];
    }
  }
}
