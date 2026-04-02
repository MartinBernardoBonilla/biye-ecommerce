// lib/features/favorites/domain/entities/favorite_item.dart
class FavoriteItem {
  final String id;
  final String productId;
  final String productName;
  final double productPrice;
  final String productImage;
  final DateTime addedAt;

  FavoriteItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.productImage,
    required this.addedAt,
  });

  // Crear desde JSON (para guardar en SharedPreferences)
  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      id: json['id'] ?? '',
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      productPrice: json['productPrice']?.toDouble() ?? 0.0,
      productImage: json['productImage'] ?? '',
      addedAt:
          DateTime.parse(json['addedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Convertir a JSON (para guardar en SharedPreferences)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productPrice': productPrice,
      'productImage': productImage,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  // Crear desde un producto (cuando se agrega a favoritos)
  factory FavoriteItem.fromProduct({
    required String productId,
    required String productName,
    required double productPrice,
    required String productImage,
  }) {
    return FavoriteItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // ID único temporal
      productId: productId,
      productName: productName,
      productPrice: productPrice,
      productImage: productImage,
      addedAt: DateTime.now(),
    );
  }
}
