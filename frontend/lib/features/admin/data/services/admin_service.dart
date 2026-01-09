import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../core/constants/app_constants.dart';
import '../../../../features/product/data/models/product_model.dart';

class AdminService {
  // TODO: Aquí deberías recuperar el token real de tu AuthProvider o SecureStorage
  String? get _token => "TU_TOKEN_JWT_AQUI";

  // ============================================
  // 1. HEADERS CON AUTORIZACIÓN
  // ============================================
  Map<String, String> _getHeaders() {
    final headers = Map<String, String>.from(AppConstants.headers);
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // ============================================
  // 2. CONEXIÓN AL BACKEND
  // ============================================
  Future<bool> testBackendConnection() async {
    try {
      final baseUrl = AppConstants.apiBaseUrl.replaceFirst("/api/v1", "");
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ============================================
  // 3. OBTENER PRODUCTOS
  // ============================================
  Future<List<ProductModel>> getAdminProducts() async {
    try {
      final url = AppConstants.buildApiUrl('/admin/products');
      final response = await http
          .get(
            Uri.parse(url),
            headers: _getHeaders(),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List productsData = data['data'] ?? [];
        return productsData.map((item) => ProductModel.fromJson(item)).toList();
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ Error en getAdminProducts: $e');
      return _getMockProducts(); // Fallback a datos locales si falla
    }
  }

  // ============================================
  // 4. AGREGAR PRODUCTO (Soporte Web/Móvil)
  // ============================================
  Future<void> addProduct({
    required String name,
    required double price,
    required String description,
    required String category,
    int countInStock = 0,
    String? brand,
    Uint8List? imageBytes, // Usamos bytes para compatibilidad Web
    String? fileName,
    BuildContext? context,
  }) async {
    try {
      // 1. Simulación de subida de imagen (Cloudinary se maneja mejor en el backend)
      String imageUrl =
          'https://res.cloudinary.com/dwchpxcrv/image/upload/v1764128386/pulseras_udxf0c.jpg';

      // 2. Preparar JSON
      final productData = {
        'name': name,
        'price': price,
        'description': description,
        'category': category,
        'countInStock': countInStock,
        if (brand != null) 'brand': brand,
        'image': {
          'url': imageUrl,
          'publicId': 'product_${DateTime.now().millisecondsSinceEpoch}',
        },
        'isActive': true,
      };

      final response = await http.post(
        Uri.parse(AppConstants.buildApiUrl('/admin/products')),
        headers: _getHeaders(),
        body: jsonEncode(productData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (context != null && context.mounted) {
          _showSnackBar(
              context, '✅ Producto creado correctamente', Colors.green);
        }
      } else {
        throw Exception('Error al crear: ${response.body}');
      }
    } catch (e) {
      print('❌ Error en addProduct: $e');
      rethrow;
    }
  }

  // ============================================
  // 5. ELIMINAR PRODUCTO
  // ============================================
  Future<void> deleteProduct(String id, {BuildContext? context}) async {
    try {
      final url = AppConstants.buildApiUrl('/admin/products/$id');
      final response = await http.delete(
        Uri.parse(url),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (context != null && context.mounted) {
          _showSnackBar(context, '✅ Producto eliminado', Colors.green);
        }
      } else {
        throw Exception('Error al eliminar: ${response.body}');
      }
    } catch (e) {
      print('❌ Error en deleteProduct: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    try {
      final url = AppConstants.buildApiUrl('/admin/products/$id');
      final response = await http.put(
        Uri.parse(url),
        headers: _getHeaders(), // Usa los headers con token que creamos
        body: jsonEncode(data),
      );

      if (response.statusCode != 200) {
        throw Exception('Error al actualizar: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // ============================================
  // HELPERS
  // ============================================

  void _showSnackBar(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  List<ProductModel> _getMockProducts() {
    return [
      ProductModel(
        id: '1',
        user: 'mock',
        name: 'Vino Malbec (Prueba)',
        description: 'Datos locales - Backend no devolvió datos reales',
        price: 29.99,
        countInStock: 10,
        category: 'Vinos',
        image: ImageModel(url: 'https://picsum.photos/200', publicId: '1'),
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        brand: 'Prueba',
      ),
    ];
  }
}

final adminService = AdminService();
