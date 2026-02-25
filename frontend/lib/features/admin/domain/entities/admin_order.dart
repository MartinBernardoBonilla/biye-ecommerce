// lib/features/admin/domain/entities/admin_order.dart
import 'admin_order_item.dart'; // 👈 IMPORTANTE

class AdminOrder {
  final String id;
  final double totalAmount;
  final String status;
  final DateTime createdAt;
  final int itemCount;
  final String? customerName;
  final String? customerEmail;
  final List<AdminOrderItem> items;
  final Map<String, dynamic>? paymentDetails;

  AdminOrder({
    required this.id,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.itemCount,
    this.customerName,
    this.customerEmail,
    this.items = const [],
    this.paymentDetails,
  });

  factory AdminOrder.fromJson(Map<String, dynamic> json) {
    final itemsData = json['items'] as List?;
    final items =
        itemsData?.map((item) => AdminOrderItem.fromJson(item)).toList() ?? [];

    final buyerInfo = json['buyerInfo'] as Map<String, dynamic>?;

    return AdminOrder(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      totalAmount: (json['totalAmount'] ?? json['total'] ?? 0).toDouble(),
      status: json['status']?.toString()?.toUpperCase() ?? 'PENDING',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      itemCount: items.length,
      customerName: buyerInfo?['name']?.toString() ?? 'Invitado',
      customerEmail: buyerInfo?['email']?.toString(),
      items: items,
      paymentDetails: json['paymentDetails'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'buyerInfo': {
        'name': customerName,
        'email': customerEmail,
      },
      'paymentDetails': paymentDetails,
    };
  }
}
