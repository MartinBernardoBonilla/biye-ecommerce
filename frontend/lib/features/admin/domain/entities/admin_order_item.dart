// lib/features/admin/domain/entities/admin_order_item.dart
class AdminOrderItem {
  final String productId;
  final String productName;
  final String? productImage;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  AdminOrderItem({
    required this.productId,
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory AdminOrderItem.fromJson(Map<String, dynamic> json) {
    // 🔥 CORRECCIÓN CRUCIAL 🔥
    // El backend envía productId como STRING, no como objeto
    String id;
    String name;
    String? image;

    final productField = json['productId'];

    if (productField is Map<String, dynamic>) {
      // Caso 1: productId es un objeto completo
      id = productField['_id']?.toString() ?? '';
      name = productField['name']?.toString() ?? 'Producto';
      image = productField['imageUrl']?.toString() ??
          productField['image']?['url']?.toString();
    } else {
      // Caso 2: productId es solo el ID string (¡ESTE ES TU CASO!)
      id = productField?.toString() ?? json['productId']?.toString() ?? '';
      name = json['name']?.toString() ?? 'Producto';
      image = json['imageUrl']?.toString() ?? json['image']?['url']?.toString();
    }

    return AdminOrderItem(
      productId: id,
      productName: name,
      productImage: image,
      quantity: (json['quantity'] ?? 1).toInt(),
      unitPrice: (json['unitPrice'] ?? json['price'] ?? 0).toDouble(),
      totalPrice: (json['totalPrice'] ??
              (json['quantity'] ?? 1) * (json['unitPrice'] ?? 0))
          .toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': productName,
      'imageUrl': productImage,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
    };
  }
}
