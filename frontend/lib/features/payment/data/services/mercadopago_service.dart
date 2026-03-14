import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:biye/core/constants/app_constants.dart'; // 👈 IMPORTAR
import 'package:biye/core/utils/auth_storage.dart'; // 👈 PARA OBTENER TOKEN

class MercadoPagoService {
  // ❌ ELIMINAR estos campos
  // final String baseUrl;
  // final String token;

  // ✅ Constructor simplificado
  MercadoPagoService();

  // Helper para obtener token
  Future<String?> _getToken() async {
    return await AuthStorage.getToken();
  }

  /// Llama a tu backend para crear la preferencia MP (checkout web)
  Future<String> createPaymentPreference(String orderId) async {
    final token = await _getToken();
    if (token == null) throw Exception('No hay token de autenticación');

    final url = Uri.parse(
      AppConstants.buildApiUrl('/payments/mercadopago/$orderId'),
    );

    print('💳 [MP] Creando preferencia en: $url');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Origin': 'http://localhost:42321',
      },
    );

    print('📥 [MP] Status: ${response.statusCode}');

    if (response.statusCode != 200) {
      print('❌ [MP] Error: ${response.body}');
      throw Exception('Error creando preferencia MercadoPago');
    }

    final data = json.decode(response.body);

    final checkoutUrl =
        data['checkoutUrl'] ?? data['init_point'] ?? data['url'];
    if (checkoutUrl == null) {
      throw Exception('No se recibió URL de checkout');
    }

    return checkoutUrl;
  }

  /// 🆕 Crea un código QR para el pago (llama a tu backend)
  ///
  /// Retorna un Map con:
  /// - qrData: La URL o string del QR
  /// - orderId: ID de la orden
  /// - expiresAt: Timestamp de expiración
  Future<Map<String, dynamic>> createQrPayment(String orderId) async {
    final token = await _getToken();
    if (token == null) throw Exception('No hay token de autenticación');

    final url = Uri.parse(
      AppConstants.buildApiUrl('/payments/mercadopago/qr/$orderId'),
    );

    print('📱 [MP] Creando QR en: $url');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Origin': 'http://localhost:42321',
      },
    );

    print('📥 [MP] Status QR: ${response.statusCode}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Error creando QR de pago');
    }

    final data = json.decode(response.body);

    return {
      'qrData': data['qrData'] ?? data['qr_data'] ?? data['qr'],
      'orderId': data['orderId'] ?? orderId,
      'expiresAt': data['expiresAt'] ?? data['expires_at'],
      'paymentId': data['paymentId'] ?? data['id'],
    };
  }

  /// 🆕 Verifica el estado del pago de una orden
  ///
  /// Retorna el estado: 'pending', 'approved', 'rejected', 'cancelled'
  Future<String> checkPaymentStatus(String orderId) async {
    final token = await _getToken();
    if (token == null) {
      print('⚠️ [MP] No hay token, retornando pending');
      return 'pending';
    }

    final url =
        Uri.parse(AppConstants.buildApiUrl('/payments/status/$orderId'));
    print('📡 [MP] Polling a: $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Origin': 'http://localhost:42321',
        },
      ).timeout(const Duration(seconds: 5));

      print('📥 [MP] Polling Status: ${response.statusCode}');

      if (response.statusCode != 200) {
        print('⚠️ [MP] Error en Polling: ${response.body}');
        return 'pending';
      }

      final data = json.decode(response.body);

      // Manejar diferentes formatos de respuesta
      final status = data['status'] ??
          data['paymentStatus'] ??
          data['data']?['status'] ??
          'pending';

      print('✅ [MP] Estado del pago: $status');
      return status;
    } catch (e) {
      print('❌ [MP] Fallo en Polling: $e');
      return 'pending';
    }
  }

  /// Opcional: Obtener información del pago
  Future<Map<String, dynamic>> getPaymentInfo(String paymentId) async {
    final token = await _getToken();
    if (token == null) throw Exception('No hay token de autenticación');

    final url =
        Uri.parse(AppConstants.buildApiUrl('/payments/info/$paymentId'));

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error obteniendo información del pago');
    }
  }
}
