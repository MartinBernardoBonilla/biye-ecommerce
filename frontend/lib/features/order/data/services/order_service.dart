import 'dart:convert';
import 'package:http/http.dart' as http;

class OrderService {
  final String baseUrl;
  final String token;

  OrderService({
    required this.baseUrl,
    required this.token,
  });

  Future<String> createOrder({
    required List<Map<String, dynamic>> items,
    required String buyerName,
    required String buyerEmail,
    String currency = 'ARS',
  }) async {
    final url = Uri.parse('$baseUrl/api/v1/orders');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'currency': currency,
        'buyerInfo': {
          'name': buyerName,
          'email': buyerEmail,
        },
        'items': items,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Error creando la orden');
    }

    final data = json.decode(response.body);
    return data['_id']; // 👈 orderId
  }
}
