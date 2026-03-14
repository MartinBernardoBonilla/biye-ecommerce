import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:biye/core/constants/app_constants.dart'; // 👈 IMPORTAR
import 'package:biye/core/utils/auth_storage.dart'; // 👈 PARA OBTENER TOKEN

class OrderService {
  // ❌ ELIMINAR estos campos
  // final String baseUrl;
  // final String token;

  // ✅ Constructor simplificado (sin parámetros)
  OrderService();

  // Helper para obtener token
  Future<String?> _getToken() async {
    return await AuthStorage.getToken();
  }

  Future<String> createOrder({
    required List<Map<String, dynamic>> items,
    required String buyerName,
    required String buyerEmail,
    String currency = 'ARS',
  }) async {
    // ✅ Usar AppConstants para la URL
    final url = Uri.parse(AppConstants.buildApiUrl('/orders'));

    // ✅ Obtener token del storage
    final token = await _getToken();

    if (token == null) {
      throw Exception('No hay token de autenticación');
    }

    print('📦 [ORDER] Creando orden en: $url');
    print('📦 [ORDER] Items: ${items.length}');
    print('📦 [ORDER] Buyer: $buyerName - $buyerEmail');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Origin': 'http://localhost:42321', // 👈 Para CORS en web
      },
      body: json.encode({
        'currency': currency,
        'buyerInfo': {
          'name': buyerName,
          'email': buyerEmail,
        },
        'items': items
            .map((item) => {
                  'productId': item['productId'],
                  'quantity': item['quantity'],
                  'price': item['price'],
                  'name': item['name'],
                })
            .toList(),
      }),
    );

    print('📥 [ORDER] Status: ${response.statusCode}');
    print('📥 [ORDER] Body: ${response.body}');

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Error creando la orden: ${response.statusCode}');
    }

    final data = json.decode(response.body);

    // Manejar diferentes formatos de respuesta
    final orderId = data['_id'] ?? data['id'] ?? data['data']?['_id'];

    if (orderId == null) {
      throw Exception('No se pudo obtener el ID de la orden');
    }

    print('✅ [ORDER] Orden creada con ID: $orderId');
    return orderId;
  }

  // 📌 Método adicional útil: obtener órdenes del usuario
  Future<List<dynamic>> getMyOrders() async {
    final url = Uri.parse(AppConstants.buildApiUrl('/orders/my-orders'));
    final token = await _getToken();

    if (token == null) {
      throw Exception('No hay token de autenticación');
    }

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] ?? data['orders'] ?? [];
    } else {
      throw Exception('Error cargando órdenes');
    }
  }

  // 📌 Método para obtener detalle de una orden
  Future<Map<String, dynamic>> getOrderById(String orderId) async {
    final url = Uri.parse(AppConstants.buildApiUrl('/orders/$orderId'));
    final token = await _getToken();

    if (token == null) {
      throw Exception('No hay token de autenticación');
    }

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] ?? data;
    } else {
      throw Exception('Error cargando detalle de orden');
    }
  }
}
