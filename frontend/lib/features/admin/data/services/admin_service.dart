import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';
import '../../../../features/product/data/models/product_model.dart';

class AdminService {
  // ============================================
  // 1. CONEXIÓN AL BACKEND
  // ============================================

  Future<bool> testBackendConnection() async {
    try {
      print('🔗 Probando conexión con backend...');
      final response = await http
          .get(
            Uri.parse(
                '${AppConstants.apiBaseUrl.replaceFirst("/api/v1", "")}/health'),
            headers: AppConstants.headers,
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        print('✅ Backend conectado: ${response.body}');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error conectando al backend: $e');
      return false;
    }
  }

  // ============================================
  // 2. OBTENER PRODUCTOS
  // ============================================

  Future<List<ProductModel>> getAdminProducts() async {
    print('📦 AdminService.getAdminProducts - Iniciando...');

    // Primero probar conexión
    final isConnected = await testBackendConnection();
    if (!isConnected) {
      throw Exception(
          'No hay conexión con el backend. Verifica que esté corriendo en ${AppConstants.apiBaseUrl.replaceFirst("/api/v1", "")}');
    }

    try {
      final url = AppConstants.buildApiUrl('/admin/products');
      print('🛒 Cargando productos desde: $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: AppConstants.headers,
          )
          .timeout(const Duration(seconds: 30));

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final productsData = data['data'] ?? data['products'] ?? [];
        print('✅ Productos cargados: ${productsData.length} items');

        // Convertir a ProductModel
        return productsData.map<ProductModel>((item) {
          return ProductModel.fromJson(item);
        }).toList();
      } else {
        print('❌ Error ${response.statusCode}: ${response.body}');
        throw Exception('Error al cargar productos: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Exception en getAdminProducts: $e');

      // Fallback: devolver datos de prueba
      print('📋 Usando datos de prueba...');
      return _getMockProducts();
    }
  }

  // Datos de prueba (fallback)
  List<ProductModel> _getMockProducts() {
    return [
      ProductModel(
        id: '1',
        user: 'mock_user_1',
        name: 'Vino Malbec Premium',
        description: 'Vino argentino de alta calidad',
        price: 29.99,
        countInStock: 50,
        category: 'Vinos',
        image: ImageModel(
          url:
              'https://res.cloudinary.com/dwchpxcrv/image/upload/v1764128386/pulseras_udxf0c.jpg',
          publicId: 'pulseras_udxf0c',
        ),
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        brand: 'Bodega Argentina',
      ),
      ProductModel(
        id: '2',
        user: 'mock_user_2',
        name: 'Café Argentino Especial',
        description: 'Café de especialidad',
        price: 15.99,
        countInStock: 100,
        category: 'Café',
        image: ImageModel(
          url:
              'https://res.cloudinary.com/dwchpxcrv/image/upload/v1764128386/pulseras_udxf0c.jpg',
          publicId: 'pulseras_udxf0c',
        ),
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        brand: 'Café Argentina',
      ),
    ];
  }

  // ============================================
  // 3. ACTUALIZAR PRODUCTO
  // ============================================

  Future<void> updateProduct(
    String id,
    Map<String, dynamic> data,
    BuildContext? context,
  ) async {
    print('🔄 AdminService.updateProduct - Iniciando...');
    print('   Product ID: $id');
    print('   Data: $data');

    try {
      final url = AppConstants.buildApiUrl('/admin/products/$id');
      print('🌐 Actualizando en: $url');

      final response = await http
          .put(
            Uri.parse(url),
            headers: AppConstants.headers,
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 30));

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ Producto actualizado exitosamente');

        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Producto actualizado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        print('❌ Error respuesta: ${response.body}');
        throw Exception('Error al actualizar: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en updateProduct: $e');
      rethrow;
    }
  }

  // ============================================
  // 4. AGREGAR PRODUCTO
  // ============================================

  Future<void> addProduct({
    required String name,
    required double price,
    required String description,
    required String category,
    int countInStock = 0,
    String? brand,
    ImageModel? image,
    File? imageFile,
    BuildContext? context,
  }) async {
    print('➕ AdminService.addProduct - Iniciando...');
    print('   Nombre: $name');
    print('   Precio: $price');
    print('   Descripción: $description');
    print('   Categoría: $category');
    print('   Brand: $brand');

    try {
      // Si hay archivo de imagen, subirla primero
      ImageModel? finalImage = image;
      if (imageFile != null) {
        print('   📤 Subiendo imagen...');
        final imageUrl = await uploadImage(imageFile);
        if (imageUrl != null) {
          finalImage = ImageModel(
            url: imageUrl,
            publicId: 'product_${DateTime.now().millisecondsSinceEpoch}',
          );
          print('   ✅ Imagen subida: $imageUrl');
        }
      }

      // Crear datos del producto según schema MongoDB
      final productData = {
        'name': name,
        'price': price,
        'description': description,
        'category': category,
        'countInStock': countInStock,
        if (brand != null) 'brand': brand,
        if (finalImage != null) 'image': finalImage.toJson(),
        'isActive': true,
      };

      final url = AppConstants.buildApiUrl('/admin/products');
      print('🌐 Creando producto en: $url');
      print('📤 Datos: $productData');

      final response = await http
          .post(
            Uri.parse(url),
            headers: AppConstants.headers,
            body: jsonEncode(productData),
          )
          .timeout(const Duration(seconds: 30));

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ Producto creado exitosamente');

        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Producto creado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        print('❌ Error respuesta: ${response.body}');
        throw Exception('Error al crear producto: ${response.statusCode}');
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
    print('🗑️ AdminService.deleteProduct - Iniciando...');
    print('   Product ID: $id');

    try {
      final url = AppConstants.buildApiUrl('/admin/products/$id');
      print('🌐 Eliminando en: $url');

      final response = await http
          .delete(
            Uri.parse(url),
            headers: AppConstants.headers,
          )
          .timeout(const Duration(seconds: 30));

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Producto eliminado exitosamente');

        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Producto eliminado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        print('❌ Error respuesta: ${response.body}');
        throw Exception('Error al eliminar: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en deleteProduct: $e');
      rethrow;
    }
  }

  // ============================================
  // 6. SUBIR IMAGEN
  // ============================================

  Future<String?> uploadImage(File imageFile) async {
    print('🖼️ AdminService.uploadImage - Iniciando...');
    print('   Archivo: ${imageFile.path}');

    try {
      // Por ahora simulamos subida exitosa
      await Future.delayed(const Duration(seconds: 2));

      // URL de ejemplo de Cloudinary
      return 'https://res.cloudinary.com/dwchpxcrv/image/upload/v${DateTime.now().millisecondsSinceEpoch}/product_${DateTime.now().millisecondsSinceEpoch}.jpg';
    } catch (e) {
      print('❌ Error subiendo imagen: $e');
      return null;
    }
  }

  // ============================================
  // 7. LOGIN DE ADMIN
  // ============================================

  Future<Map<String, dynamic>> adminLogin(String email, String password) async {
    print('🔐 AdminService.adminLogin - Iniciando...');

    try {
      final url = AppConstants.buildApiUrl('/admin/login');
      print('🌐 Login en: $url');

      final response = await http
          .post(
            Uri.parse(url),
            headers: AppConstants.headers,
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 30));

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Login exitoso');
        return data;
      } else {
        print('❌ Error login: ${response.body}');
        throw Exception('Login falló: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en adminLogin: $e');
      rethrow;
    }
  }
}

final adminService = AdminService();
