import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:biye/features/product/data/models/product_model.dart';
import 'package:biye/core/constants/app_constants.dart'; // 👈 IMPORTAR

class ProductService {
  // ❌ ELIMINAR esta línea
  // final String baseUrl = 'http://localhost:5000/api/v1';

  // ✅ Usar AppConstants
  String get baseUrl => AppConstants.apiBaseUrl;

  Future<List<ProductModel>> fetchProducts() async {
    try {
      final url =
          AppConstants.buildApiUrl(AppConstants.apiProducts); // 👈 NUEVO
      print('🛒 [DEBUG] Cargando productos desde: $url');

      final response = await http.get(
        Uri.parse(url), // 👈 USAR URL CONSTRUIDA
        headers: {
          'Origin': 'https://biye-app.vercel.app',
          'Accept': 'application/json',
        },
      );

      print('📥 [DEBUG] Status: ${response.statusCode}');
      print(
        '📥 [DEBUG] Body: ${response.body.length > 200 ? "${response.body.substring(0, 200)}..." : response.body}',
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print('📊 [DEBUG] Success: ${jsonResponse['success']}');
        print('📊 [DEBUG] Count: ${jsonResponse['count']}');
        print('📊 [DEBUG] Has data: ${jsonResponse.containsKey('data')}');
        print('📊 [DEBUG] Data type: ${jsonResponse['data']?.runtimeType}');
        print(
          '📊 [DEBUG] Data length: ${(jsonResponse['data'] as List?)?.length ?? 0}',
        );

        if (jsonResponse['success'] == true && jsonResponse['data'] is List) {
          final products = (jsonResponse['data'] as List).map((item) {
            print('🔄 [DEBUG] Procesando producto: ${item['name']}');
            return ProductModel.fromJson(item);
          }).toList();

          print('✅ [DEBUG] Productos convertidos: ${products.length}');

          if (products.isNotEmpty && products[0].image != null) {
            print(
              '🖼️ [DEBUG] Primer producto imagen URL: ${products[0].image!.url}',
            );
          } else if (products.isNotEmpty) {
            print('🖼️ [DEBUG] Primer producto sin imagen');
          }

          return products;
        } else {
          print('❌ [DEBUG] Respuesta no tiene formato esperado');
          return [];
        }
      } else {
        print('❌ [DEBUG] Error HTTP: ${response.statusCode}');
        print('❌ [DEBUG] Response: ${response.body}');
        return [];
      }
    } catch (error) {
      print('❌ [DEBUG] Exception: $error');
      print('❌ [DEBUG] Stack trace: ${error.toString()}');
      return [];
    }
  }

  Future<ProductModel?> fetchProductById(String id) async {
    try {
      final url = AppConstants.buildApiUrl(
          '${AppConstants.apiProducts}/$id'); // 👈 NUEVO
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Origin': 'https://biye-app.vercel.app',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          return ProductModel.fromJson(jsonResponse['data']);
        }
      } else {
        print('❌ [DEBUG] Error al cargar producto $id: ${response.statusCode}');
      }
      return null;
    } catch (error) {
      print('❌ [DEBUG] Error al cargar producto: $error');
      return null;
    }
  }
}
