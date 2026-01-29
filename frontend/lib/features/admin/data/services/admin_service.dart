import '../../../../core/network/api_client.dart';
import 'package:biye/features/product/data/models/product_model.dart';

class AdminService {
  final ApiClient apiClient;

  AdminService({required this.apiClient});

  // =========================
  // GET PRODUCTS
  // =========================
  Future<List<ProductModel>> getAdminProducts() async {
    final response = await apiClient.get('admin/products');

    final List data = response['data'] ?? [];

    return data.map((e) => ProductModel.fromJson(e)).toList();
  }

  // =========================
  // CREATE PRODUCT
  // =========================
  Future<void> createProduct({
    required String name,
    required double price,
    required String description,
    required String category,
    required int countInStock,
  }) async {
    final body = {
      'name': name,
      'price': price,
      'description': description,
      'category': category,
      'countInStock': countInStock,
      'isActive': true,
    };

    await apiClient.post('admin/products', body);
  }

  // =========================
  // UPDATE PRODUCT
  // =========================
  Future<void> updateProduct(
    String productId,
    Map<String, dynamic> data,
  ) async {
    await apiClient.put('admin/products/$productId', data);
  }

  // =========================
  // DELETE PRODUCT
  // =========================
  Future<void> deleteProduct(String productId) async {
    await apiClient.delete('admin/products/$productId');
  }
}
