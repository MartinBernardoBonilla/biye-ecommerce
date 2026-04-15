// lib/features/checkout/data/repositories/checkout_repository.dart

import 'package:biye/core/network/api_client.dart';
import 'package:flutter/foundation.dart';

import '../../../order/domain/entities/order.dart';

class CheckoutRepository {
  final ApiClient _apiClient;

  CheckoutRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  // Crear orden desde objeto Order
  Future<Order?> createOrder(Order order) async {
    try {
      debugPrint('🛒 Creando orden desde Order object...');
      final response = await _apiClient.post('orders', order.toJson());

      if (response['success'] == true) {
        debugPrint('✅ Orden creada exitosamente');
        return Order.fromJson(response['order']);
      }
      debugPrint('❌ La respuesta no indicó success: $response');
      return null;
    } catch (e) {
      debugPrint('❌ Error creando orden: $e');
      return null;
    }
  }

  // Crear orden con pago QR
  Future<QrPaymentResponse?> createQrPayment(
      Map<String, dynamic> orderData) async {
    try {
      debugPrint('📱 Creando pago QR...');
      debugPrint('📦 Datos enviados: ${orderData.keys}');

      final response = await _apiClient.post('orders/qr-payment', orderData);

      debugPrint('📥 Respuesta completa del QR: $response');

      if (response['success'] == true) {
        debugPrint('✅ QR generado exitosamente');
        return QrPaymentResponse.fromJson(response);
      }

      debugPrint('❌ El backend no retornó success=true');
      debugPrint('📥 Respuesta: $response');
      return null;
    } catch (e) {
      debugPrint('❌ Error creando pago QR: $e');
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
      debugPrint('❌ Error obteniendo orden: $e');
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
      debugPrint('❌ Error iniciando pago: $e');
      return null;
    }
  }

  // Verificar estado de pago QR
  Future<QrPaymentStatus?> checkQrPaymentStatus(String orderId) async {
    try {
      final response = await _apiClient.get('orders/$orderId/payment-status');

      if (response['success'] == true) {
        return QrPaymentStatus.fromJson(response);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error verificando pago QR: $e');
      return null;
    }
  }
}

// Respuesta para pago QR
class QrPaymentResponse {
  final String orderId;
  final String qrCode;
  final String? qrCodeBase64;

  QrPaymentResponse({
    required this.orderId,
    required this.qrCode,
    this.qrCodeBase64,
  });

  factory QrPaymentResponse.fromJson(Map<String, dynamic> json) {
    debugPrint('🔍 Parseando QrPaymentResponse desde: $json');

    // Intenta diferentes formas de obtener los datos
    final orderId =
        json['orderId'] ?? json['order']?['_id'] ?? json['order']?['id'] ?? '';

    final qrCode = json['qrCode'] ?? json['qr_image'] ?? json['qr'] ?? '';

    final qrCodeBase64 =
        json['qrCodeBase64'] ?? json['qr_base64'] ?? json['qrImage'] ?? null;

    debugPrint(
        '✅ Parseado - orderId: $orderId, qrCode: ${qrCode.substring(0, qrCode.length > 50 ? 50 : qrCode.length)}...');

    return QrPaymentResponse(
      orderId: orderId,
      qrCode: qrCode,
      qrCodeBase64: qrCodeBase64,
    );
  }
}

// Estado de pago QR
class QrPaymentStatus {
  final String status;
  final String? paymentId;
  final DateTime? paidAt;

  QrPaymentStatus({
    required this.status,
    this.paymentId,
    this.paidAt,
  });

  factory QrPaymentStatus.fromJson(Map<String, dynamic> json) {
    return QrPaymentStatus(
      status: json['status'] ?? 'PENDING',
      paymentId: json['paymentId'],
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
    );
  }

  bool get isPaid => status == 'PAID';
  bool get isPending => status == 'PENDING';
  bool get isExpired => status == 'EXPIRED';
  bool get isFailed => status == 'FAILED';
}
