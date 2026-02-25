// lib/features/admin/domain/repositories/admin_repository.dart
import '../entities/admin_stats.dart';
import '../entities/admin_order.dart';

abstract class AdminRepository {
  Future<AdminStats> getDashboardStats();
  Future<List<AdminOrder>> getRecentOrders({int limit = 5});
  Future<List<AdminOrder>> getOrders({int page = 1, int limit = 20});
  Future<List<dynamic>> getUsers({int page = 1, int limit = 20});
}
