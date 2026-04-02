// lib/features/checkout/data/repositories/checkout_repository.dart

import 'package:biye/core/network/api_client.dart';
import '../../../order/domain/entities/order.dart';

class CheckoutRepository {
  final ApiClient _apiClient;

  CheckoutRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  // Crear orden
  Future<Order?> createOrder(Order order) async {
    try {
      final response = await _apiClient.post('orders', order.toJson());

      if (response['success'] == true) {
        return Order.fromJson(response['order']);
      }
      return null;
    } catch (e) {
      print('❌ Error creando orden: $e');
      return null;
    }
  }

  // Obtener orden por ID
  Future<Order?> getOrder(String id) async {
    try {
      final response = await _apiClient.get('orders/$id');

      if (response['success'] == true) {
        return Order.fromJson(response['order']);
      }
      return null;
    } catch (e) {
      print('❌ Error obteniendo orden: $e');
      return null;
    }
  }

  // Iniciar pago con MercadoPago
  Future<String?> initiatePayment(String orderId) async {
    try {
      final response = await _apiClient.post('payments/initiate', {
        'orderId': orderId,
      });

      if (response['success'] == true) {
        return response['paymentUrl'];
      }
      return null;
    } catch (e) {
      print('❌ Error iniciando pago: $e');
      return null;
    }
  }
}
