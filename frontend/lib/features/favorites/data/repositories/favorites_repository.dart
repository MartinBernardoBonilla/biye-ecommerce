import 'package:biye/core/network/api_client.dart';
import '../../domain/entities/favorite_item.dart';

class FavoritesRepository {
  final ApiClient apiClient;

  FavoritesRepository({required this.apiClient});

  Future<List<FavoriteItem>> getFavorites() async {
    try {
      final response = await apiClient.get('favorites');
      print('📡 [REPO] GET favorites - Response: $response');

      if (response['success'] == true) {
        final List favorites = response['favorites'];
        print('📡 [REPO] Favoritos obtenidos: ${favorites.length}');
        return favorites.map((json) => FavoriteItem.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ [REPO] Error getting favorites: $e');
      return [];
    }
  }

  Future<bool> addFavorite(FavoriteItem item) async {
    try {
      final response = await apiClient.post(
        'favorites',
        {
          'productId': item.productId,
        },
      );

      print('📡 [REPO] POST favorites - Response: $response');
      return response['success'] == true;
    } catch (e) {
      print('❌ [REPO] Error adding favorite: $e');
      return false;
    }
  }

  Future<bool> removeFavorite(String productId) async {
    try {
      final response = await apiClient.delete('favorites/$productId');

      print('📡 [REPO] DELETE favorites/$productId - Response: $response');
      return response['success'] == true;
    } catch (e) {
      print('❌ [REPO] Error removing favorite: $e');
      return false;
    }
  }

  Future<bool> isFavorite(String productId) async {
    try {
      final response = await apiClient.get('favorites/$productId');

      print('📡 [REPO] GET favorites/$productId - Response: $response');
      return response['isFavorite'] == true;
    } catch (e) {
      print('❌ [REPO] Error checking favorite: $e');
      return false;
    }
  }
}
