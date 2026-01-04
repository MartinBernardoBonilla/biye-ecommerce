// lib/core/utils/deep_link_handler.dart
import 'package:flutter/services.dart';

class DeepLinkHandler {
  static const MethodChannel _channel = MethodChannel('biye/deep_links');

  // Callback para manejar los deep links
  static Function(String)? _onDeepLink;

  static void initialize() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  static Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onDeepLink':
        final String link = call.arguments as String;
        _onDeepLink?.call(link);
        break;
    }
  }

  // Configurar callback para deep links
  static void setOnDeepLinkCallback(Function(String) callback) {
    _onDeepLink = callback;
  }

  // Manejar respuesta de MercadoPago
  static PaymentResult parsePaymentResult(String deepLink) {
    final uri = Uri.parse(deepLink);
    final path = uri.path;
    final queryParams = uri.queryParameters;

    if (path.contains('/payment/success')) {
      return PaymentResult(
        status: PaymentResultStatus.success,
        paymentId: queryParams['payment_id'],
        merchantOrderId: queryParams['merchant_order_id'],
        preferenceId: queryParams['preference_id'],
      );
    } else if (path.contains('/payment/failure')) {
      return PaymentResult(
        status: PaymentResultStatus.failure,
        paymentId: queryParams['payment_id'],
        merchantOrderId: queryParams['merchant_order_id'],
        preferenceId: queryParams['preference_id'],
      );
    } else if (path.contains('/payment/pending')) {
      return PaymentResult(
        status: PaymentResultStatus.pending,
        paymentId: queryParams['payment_id'],
        merchantOrderId: queryParams['merchant_order_id'],
        preferenceId: queryParams['preference_id'],
      );
    }

    return PaymentResult(status: PaymentResultStatus.unknown);
  }
}

// Enums y modelos para resultados de pago
enum PaymentResultStatus { success, failure, pending, unknown }

class PaymentResult {
  final PaymentResultStatus status;
  final String? paymentId;
  final String? merchantOrderId;
  final String? preferenceId;

  PaymentResult({
    required this.status,
    this.paymentId,
    this.merchantOrderId,
    this.preferenceId,
  });

  bool get isSuccess => status == PaymentResultStatus.success;
  bool get isFailure => status == PaymentResultStatus.failure;
  bool get isPending => status == PaymentResultStatus.pending;
}
