import 'dart:convert';
import 'package:http/http.dart' as http;

class MercadoPagoService {
  final String baseUrl;
  final String token;

  MercadoPagoService({
    required this.baseUrl,
    required this.token,
  });

  /// Llama a tu backend para crear la preferencia MP
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

    // 🔥 ESTA ERA LA LÍNEA ROTA
    return data['checkoutUrl'];
  }
}
