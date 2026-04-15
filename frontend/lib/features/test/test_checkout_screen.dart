// lib/features/test/test_checkout_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../core/network/api_client.dart';
import '../../features/checkout/data/repositories/checkout_repository.dart';

class TestCheckoutScreen extends StatefulWidget {
  const TestCheckoutScreen({Key? key}) : super(key: key);

  @override
  State<TestCheckoutScreen> createState() => _TestCheckoutScreenState();
}

class _TestCheckoutScreenState extends State<TestCheckoutScreen> {
  final ApiClient _apiClient = ApiClient();
  late CheckoutRepository _repository;
  String _resultado = '';
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _repository = CheckoutRepository(apiClient: _apiClient);

    // Para pruebas, puedes cargar un token manualmente
    _cargarTokenParaPrueba();
  }

  Future<void> _cargarTokenParaPrueba() async {
    // TODO: Reemplaza con un token real de tu app
    // Puedes obtenerlo del login o poner uno manual para pruebas
    final token = await _obtenerTokenDeAuthStorage();
    if (token != null && token.isNotEmpty) {
      await _apiClient.setToken(token);
      debugPrint('✅ Token cargado para pruebas');
    } else {
      debugPrint('⚠️ No hay token - las pruebas pueden fallar');
    }
  }

  Future<String?> _obtenerTokenDeAuthStorage() async {
    // Importa tu AuthStorage aquí
    // return await AuthStorage.getToken();
    return null; // Temporal
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Checkout'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _testQrPayment,
              icon: const Icon(Icons.qr_code),
              label: const Text('Probar Pago QR'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _testNormalPayment,
              icon: const Icon(Icons.payment),
              label: const Text('Probar Pago Normal'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            Row(
              children: [
                const Icon(Icons.info_outline, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Resultado:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                if (_cargando)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _resultado.isEmpty
                        ? 'Presiona un botón para probar...'
                        : _resultado,
                    style:
                        const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testQrPayment() async {
    setState(() {
      _cargando = true;
      _resultado = '🔍 Probando pago QR...\n\n';
    });

    try {
      // Datos de prueba para QR
      final qrData = {
        'items': [
          {
            'id': 'test_product_1',
            'name': 'Producto Test QR',
            'price': 500,
            'quantity': 1,
            'imageUrl': 'https://test.com/image.jpg',
            'description': 'Producto de prueba para QR'
          }
        ],
        'shippingAddress': {
          'alias': 'Casa',
          'recipientName': 'Juan Perez',
          'phone': '123456789',
          'street': 'Av. Siempre Viva',
          'number': '742',
          'apartment': null,
          'city': 'Springfield',
          'state': 'Capital',
          'postalCode': '1234',
          'country': 'Argentina',
          'isDefault': true,
          'instructions': null
        },
        'paymentMethod': {
          'id': 'qr_method_1',
          'type': 'QR',
          'name': 'MercadoPago QR',
          'displayName': 'Pagar con QR',
          'isDefault': false
        },
        'subtotal': 500,
        'shippingCost': 0,
        'tax': 105,
        'total': 605,
        'currency': 'ARS',
        'buyerInfo': {'email': 'test@example.com', 'name': 'Juan Perez'},
        'paymentType': 'QR'
      };

      _resultado += '📤 Enviando request a /orders/qr-payment\n';
      _resultado += '📦 Datos: ${qrData.keys.join(', ')}\n\n';
      setState(() {});

      final response = await _repository.createQrPayment(qrData);

      if (response != null) {
        _resultado += '✅ ÉXITO!\n';
        _resultado += '━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
        _resultado += '📌 orderId: ${response.orderId}\n';
        _resultado += '📌 qrCode: ${response.qrCode}\n';
        _resultado +=
            '📌 qrCodeBase64: ${response.qrCodeBase64 != null ? "✅ Presente (${response.qrCodeBase64!.length} chars)" : "❌ No presente"}\n';
        _resultado += '━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';

        if (response.qrCodeBase64 != null) {
          _resultado +=
              '\n💡 El QR está en base64, puedes mostrarlo con Image.memory()\n';
        } else if (response.qrCode.isNotEmpty) {
          _resultado += '\n💡 QR Code: ${response.qrCode}\n';
        }
      } else {
        _resultado += '❌ FALLO: El repositorio retornó null\n';
        _resultado += 'Revisa los logs para más detalles\n';
      }
    } catch (e) {
      _resultado += '❌ ERROR: $e\n';
    }

    setState(() => _cargando = false);
  }

  Future<void> _testNormalPayment() async {
    setState(() {
      _cargando = true;
      _resultado = '🔍 Probando pago normal...\n\n';
    });

    try {
      final orderData = {
        'items': [
          {
            'id': 'test_product_1',
            'name': 'Producto Test',
            'price': 1000,
            'quantity': 2,
            'imageUrl': '',
            'description': 'Test description'
          }
        ],
        'shippingAddress': {
          'alias': 'Casa',
          'recipientName': 'Juan Perez',
          'phone': '123456789',
          'street': 'Av. Siempre Viva',
          'number': '742',
          'city': 'Springfield',
          'state': 'Capital',
          'postalCode': '1234',
          'country': 'Argentina',
          'isDefault': true
        },
        'paymentMethod': {
          'id': 'card_1',
          'type': 'card',
          'name': 'Visa',
          'displayName': 'Visa **** 1234',
          'isDefault': true
        },
        'subtotal': 2000,
        'shippingCost': 500,
        'tax': 420,
        'total': 2920,
        'currency': 'ARS',
        'buyerInfo': {'email': 'test@example.com', 'name': 'Juan Perez'}
      };

      _resultado += '📤 Enviando request a /orders\n';
      setState(() {});

      final response = await _apiClient.post('orders', orderData);

      _resultado += '✅ Respuesta recibida!\n';
      _resultado += '━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
      _resultado += '📦 Data: ${response.toString()}\n';
      _resultado += '━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n';
    } catch (e) {
      _resultado += '❌ ERROR: $e\n';
    }

    setState(() => _cargando = false);
  }
}
