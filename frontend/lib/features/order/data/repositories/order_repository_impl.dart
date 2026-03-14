// lib/features/order/data/repositories/order_repository_impl.dart
import 'package:biye/features/order/domain/repositories/order_repository.dart';
import 'package:biye/features/order/domain/entities/order_entity.dart';
import 'package:biye/features/order/data/datasources/order_remote_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<OrderEntity>> getMyOrders() async {
    try {
      final response = await remoteDataSource.getMyOrders();
      final List<dynamic> ordersData = response['data'] ?? response;

      return ordersData.map((json) => OrderEntity.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al cargar órdenes: $e');
    }
  }

  @override
  Future<OrderEntity> getOrderById(String orderId) async {
    try {
      final response = await remoteDataSource.getOrderById(orderId);
      final orderData = response['data'] ?? response;

      return OrderEntity.fromJson(orderData);
    } catch (e) {
      throw Exception('Error al cargar orden: $e');
    }
  }

  @override
  Future<String> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await remoteDataSource.createOrder(orderData);
      return response['data']?['_id']?.toString() ??
          response['_id']?.toString() ??
          '';
    } catch (e) {
      throw Exception('Error al crear orden: $e');
    }
  }
}
