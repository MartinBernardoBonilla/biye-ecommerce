// lib/features/order/domain/repositories/order_repository.dart
import 'package:biye/features/order/domain/entities/order_entity.dart';

abstract class OrderRepository {
  /// Obtiene todas las órdenes del usuario autenticado
  Future<List<OrderEntity>> getMyOrders();

  /// Obtiene una orden específica por su ID
  Future<OrderEntity> getOrderById(String orderId);

  /// Crea una nueva orden
  Future<String> createOrder(Map<String, dynamic> orderData);
}
