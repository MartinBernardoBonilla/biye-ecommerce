import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:biye/core/constants/app_constants.dart';
import 'package:biye/core/utils/auth_storage.dart';

class ShippingService {
  ShippingService();

  // Helper para recuperar el token JWT guardado de forma segura
  Future<String?> _getToken() async {
    return await AuthStorage.getToken();
  }

  /// Obtiene los detalles de logística y tracking de una orden específica
  Future<Map<String, dynamic>> getShippingDetails(String orderId) async {
    // Construye dinámicamente: http://localhost:5000/api/v1/shipping/track/$orderId
    final url = Uri.parse(AppConstants.buildApiUrl('/shipping/track/$orderId'));
    final token = await _getToken();

    if (token == null) {
      throw Exception('No se encontró un token de autenticación válido.');
    }

    print('🚚 [SHIPPING SERVICE] Solicitando tracking para orden: $orderId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    print('📥 [SHIPPING SERVICE] Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      // Retornamos el nodo de datos (adaptalo según cómo responda tu shipping.manager.js)
      return decodedData['data'] ?? decodedData;
    } else if (response.statusCode == 404) {
      throw Exception('El envío para esta orden aún no fue generado.');
    } else {
      throw Exception(
          'Error al obtener la información de envío (Status: ${response.statusCode})');
    }
  }
}
