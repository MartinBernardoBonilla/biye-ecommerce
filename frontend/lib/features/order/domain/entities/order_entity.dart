// lib/features/order/domain/entities/order_entity.dart
class OrderEntity {
  final String id;
  final double totalAmount;
  final String status;
  final DateTime createdAt;
  final int itemCount;
  final List<OrderItemEntity> items;

  OrderEntity({
    required this.id,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.itemCount,
    required this.items,
  });

  factory OrderEntity.fromJson(Map<String, dynamic> json) {
    final itemsData = json['items'] as List?;
    final items =
        itemsData?.map((e) => OrderItemEntity.fromJson(e)).toList() ?? [];

    return OrderEntity(
      id: json['_id']?.toString() ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: json['status'] ?? 'PENDING',
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      itemCount: items.length,
      items: items,
    );
  }
}

class OrderItemEntity {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  OrderItemEntity({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory OrderItemEntity.fromJson(Map<String, dynamic> json) {
    return OrderItemEntity(
      productId: json['productId']?['_id']?.toString() ??
          json['productId']?.toString() ??
          '',
      productName: json['name'] ?? json['productId']?['name'] ?? 'Producto',
      quantity: (json['quantity'] ?? 0).toInt(),
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
    );
  }
}
