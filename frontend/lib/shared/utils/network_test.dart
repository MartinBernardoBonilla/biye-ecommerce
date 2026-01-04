import 'dart:convert';
import 'package:http/http.dart' as http;

class NetworkTest {
  // Probar conexión básica
  static Future<void> testBackendConnection() async {
    print('🔍 PROBANDO CONEXIÓN BACKEND');
    print('=============================');

    const testUrls = [
      'http://192.168.1.49:5000/',
      'http://192.168.1.49:5000/health',
      'http://192.168.1.49:5000/api/v1/products',
      'http://localhost:5000/health', // fallback
    ];

    for (var url in testUrls) {
      try {
        print('\n🌐 Probando: $url');
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ).timeout(Duration(seconds: 5));

        print('✅ Status: ${response.statusCode}');
        if (response.statusCode == 200) {
          try {
            final data = jsonDecode(response.body);
            print(
                '📄 Respuesta: ${data is Map ? data['message'] ?? data['status'] : 'Datos recibidos'}');
          } catch (e) {
            print('📄 Respuesta: ${response.body.substring(0, 100)}...');
          }
        }
      } catch (e) {
        print('❌ Error: $e');
      }
    }

    print('\n🎯 Resultado:');
    print('   Backend: http://192.168.1.49:5000');
    print('   API: http://192.168.1.49:5000/api/v1');
  }

  // Probar desde la consola de Flutter
  static void runTest() {
    testBackendConnection().then((_) {
      print('\n✅ Prueba completada');
    }).catchError((e) {
      print('\n❌ Error en prueba: $e');
    });
  }
}
