import 'package:biye/features/cart/domain/entities/cart_item.dart';

// Este servicio simula la llamada al backend de Node.js que se encarga
// de comunicarse con la API de Mercado Pago y generar la Preferencia.
class MercadoPagoService {
  // Aquí se llamaría a tu API de Node.js para generar la preferencia de pago.
  // Tu backend debe retornar un objeto con el ID de la preferencia.
  Future<String> createPreference(List<CartItem> items, double total) async {
    // Implementación real:
    /*
    final url = Uri.parse('TU_URL_DE_NGROK/api/v1/payment/create-preference');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'items': items.map((e) => e.toJson()).toList(),
        'total': total,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['preferenceId'] as String;
    } else {
      throw Exception('Fallo al crear la preferencia de pago');
    }
    */

    // --- MOCK TEMPORAL ---
    await Future.delayed(const Duration(seconds: 1));
    if (total > 0) {
      // Simula un ID de preferencia retornado por el backend
      return 'MP-ID-ABC-123-${DateTime.now().millisecondsSinceEpoch}';
    } else {
      throw Exception('El carrito está vacío o el total es cero.');
    }
  }
}
