// lib/features/order/domain/repositories/order_repository.dart

import '../entities/order.dart';

abstract class OrderRepository {
  Future<Order?> createOrder(Order order);
  Future<Order?> getOrder(String id);
  Future<List<Order>> getUserOrders();
}
