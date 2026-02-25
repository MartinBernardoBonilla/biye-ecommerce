// lib/features/admin/domain/entities/admin_stats.dart
import 'package:biye/features/admin/domain/entities/admin_order.dart';

class AdminStats {
  final int totalProducts;
  final int lowStockCount;
  final int outOfStockCount;
  final int activeProducts;
  final int totalOrders;
  final int pendingOrders;
  final int totalUsers;
  final List<AdminOrder> recentOrders;

  AdminStats({
    required this.totalProducts,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.activeProducts,
    required this.totalOrders,
    required this.pendingOrders,
    required this.totalUsers,
    required this.recentOrders,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    // 🔥 CORRECCIÓN CRUCIAL: Los datos están dentro de 'data'
    final data = json['data'] is Map ? json['data'] : json;

    return AdminStats(
      totalProducts: data['totalProducts'] ?? 0,
      lowStockCount: data['lowStockCount'] ?? 0,
      outOfStockCount: data['outOfStockCount'] ?? 0,
      activeProducts: data['activeProducts'] ?? 0,
      totalOrders: data['totalOrders'] ?? 0,
      pendingOrders: data['pendingOrders'] ?? 0,
      totalUsers: data['totalUsers'] ?? 0,
      recentOrders: (data['recentOrders'] as List?)
              ?.map((o) => AdminOrder.fromJson(o))
              .toList() ??
          [],
    );
  }

  // Para crear un estado vacío (útil para inicialización)
  factory AdminStats.empty() {
    return AdminStats(
      totalProducts: 0,
      lowStockCount: 0,
      outOfStockCount: 0,
      activeProducts: 0,
      totalOrders: 0,
      pendingOrders: 0,
      totalUsers: 0,
      recentOrders: [],
    );
  }
}
