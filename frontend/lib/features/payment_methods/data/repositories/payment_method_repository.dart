import 'package:biye/core/network/api_client.dart';
import '../../domain/entities/payment_method.dart';

class PaymentMethodRepository {
  final ApiClient _apiClient;

  PaymentMethodRepository({required ApiClient apiClient})
      : _apiClient = apiClient;

  // Obtener todos los métodos de pago
  Future<List<PaymentMethod>> getPaymentMethods() async {
    try {
      final response = await _apiClient.get('payment-methods');

      if (response['success'] == true) {
        final List<dynamic> methodsJson = response['methods'];
        return methodsJson.map((json) => PaymentMethod.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Error obteniendo métodos de pago: $e');
      return [];
    }
  }

  // Agregar tarjeta
  Future<PaymentMethod?> addCard({
    required String lastFourDigits,
    required String brand,
    required String expirationMonth,
    required String expirationYear,
    required String cardholderName,
    bool isDefault = false,
  }) async {
    try {
      final response = await _apiClient.post('payment-methods', {
        'lastFourDigits': lastFourDigits,
        'brand': brand.toLowerCase(),
        'expirationMonth': expirationMonth,
        'expirationYear': expirationYear,
        'cardholderName': cardholderName,
        'isDefault': isDefault,
      });

      if (response['success'] == true) {
        return PaymentMethod.fromJson(response['method']);
      }
      return null;
    } catch (e) {
      print('❌ Error agregando tarjeta: $e');
      return null;
    }
  }

  // Eliminar método de pago
  Future<bool> deletePaymentMethod(String id) async {
    try {
      await _apiClient.delete('payment-methods/$id');
      return true;
    } catch (e) {
      print('❌ Error eliminando método de pago: $e');
      return false;
    }
  }

  // Establecer como predeterminado
  Future<PaymentMethod?> setDefaultPaymentMethod(String id) async {
    try {
      final response = await _apiClient.put('payment-methods/default/$id', {});

      if (response['success'] == true) {
        return PaymentMethod.fromJson(response['method']);
      }
      return null;
    } catch (e) {
      print('❌ Error estableciendo método predeterminado: $e');
      return null;
    }
  }
}
