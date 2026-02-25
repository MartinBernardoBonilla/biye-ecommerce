import 'dart:convert';
import 'package:http/http.dart' as http;

class MercadoPagoService {
  final String baseUrl;
  final String token;

  MercadoPagoService({
    required this.baseUrl,
    required this.token,
  });

  /// Llama a tu backend para crear la preferencia MP (checkout web)
  Future<String> createPaymentPreference(String orderId) async {
    final url = Uri.parse(
      '$baseUrl/api/v1/payments/mercadopago/$orderId',
    );

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Error creando preferencia MercadoPago');
    }

    final data = json.decode(response.body);

    return data['checkoutUrl'];
  }

  /// 🆕 Crea un código QR para el pago (llama a tu backend)
  ///
  /// Retorna un Map con:
  /// - qrData: La URL o string del QR
  /// - orderId: ID de la orden
  /// - expiresAt: Timestamp de expiración
  Future<Map<String, dynamic>> createQrPayment(String orderId) async {
    final url = Uri.parse(
      '$baseUrl/api/v1/payments/mercadopago/qr/$orderId',
    );

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Error creando QR de pago');
    }

    final data = json.decode(response.body);

    return {
      'qrData': data['qrData'] ?? data['qr_data'],
      'orderId': data['orderId'] ?? orderId,
      'expiresAt': data['expiresAt'] ?? data['expires_at'],
      'paymentId': data['paymentId'],
    };
  }

  /// 🆕 Verifica el estado del pago de una orden
  ///
  /// Retorna el estado: 'pending', 'approved', 'rejected', 'cancelled'
  Future<String> checkPaymentStatus(String orderId) async {
    final url = Uri.parse('$baseUrl/api/v1/payments/status/$orderId');
    print('📡 POLLING A: $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      ).timeout(
          const Duration(seconds: 5)); // Agregamos un timeout por seguridad

      if (response.statusCode != 200) {
        // Aquí es donde ves el <!DOCTYPE... si la ruta está mal
        print('⚠️ Error en Polling (${response.statusCode}): ${response.body}');
        return 'pending';
      }

      final data = json.decode(response.body);
      return data['status'] ?? 'pending';
    } catch (e) {
      print('❌ Fallo de conexión en Polling: $e');
      return 'pending'; // Si falla la red, seguimos esperando
    }
  }
}
