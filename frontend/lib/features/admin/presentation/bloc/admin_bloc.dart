// lib/features/admin/presentation/bloc/admin_bloc.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:biye/features/admin/domain/entities/admin_stats.dart';
import 'package:biye/features/admin/domain/entities/admin_order.dart';
import 'package:biye/features/admin/domain/repositories/admin_repository.dart';

part 'admin_event.dart';
part 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository _repository;

  AdminBloc({required AdminRepository repository})
      : _repository = repository,
        super(AdminInitial()) {
    on<LoadAdminDashboard>(_onLoadDashboard);
    on<LoadOrders>(_onLoadOrders);
    on<LoadUsers>(_onLoadUsers);
    on<RefreshAdminData>(_onRefreshData);
  }

  Future<void> _onLoadDashboard(
    LoadAdminDashboard event,
    Emitter<AdminState> emit,
  ) async {
    // PRESERVAR usuarios y órdenes existentes
    final List<AdminOrder> currentOrders =
        state is AdminLoaded ? (state as AdminLoaded).orders : [];

    final List<dynamic> currentUsers =
        state is AdminLoaded ? (state as AdminLoaded).users : [];

    debugPrint(
        '📊 [BLOC] Dashboard - Usuarios actuales: ${currentUsers.length}');

    emit(AdminLoading());

    try {
      // 🔥 Cargar stats y órdenes en paralelo
      final stats = await _repository.getDashboardStats();
      final recentOrders = await _repository.getRecentOrders(limit: 5);

      // 🔥 NUEVO: Cargar primera página de usuarios
      List<dynamic> firstPageUsers = [];
      try {
        firstPageUsers = await _repository.getUsers(page: 1, limit: 10);
        debugPrint('👥 [BLOC] Usuarios cargados: ${firstPageUsers.length}');
      } catch (e) {
        debugPrint('⚠️ [BLOC] Error cargando usuarios (no fatal): $e');
        // Continuamos sin usuarios si falla
      }

      emit(AdminLoaded(
        stats: stats,
        orders: currentOrders.isEmpty ? recentOrders : currentOrders,
        users: firstPageUsers, // ← AHORA SÍ se cargan
        hasMoreOrders: false,
        hasMoreUsers: firstPageUsers.length >= 10,
      ));

      debugPrint('📊 [BLOC] Dashboard cargado - Stats OK');
      debugPrint('👥 [BLOC] Usuarios en estado: ${firstPageUsers.length}');
    } catch (e) {
      debugPrint('❌ [BLOC] Error cargando dashboard: $e');
      emit(AdminError(message: e.toString()));
    }
  }

  Future<void> _onLoadOrders(
    LoadOrders event,
    Emitter<AdminState> emit,
  ) async {
    debugPrint('🔄 [BLOC] Cargando órdenes - Página: ${event.page}');

    try {
      debugPrint('🔄 [BLOC] Llamando a repository.getOrders()');
      final orders = await _repository.getOrders(
        page: event.page,
        limit: event.limit,
      );
      debugPrint('✅ [BLOC] Órdenes recibidas: ${orders.length}');

      final hasMore = orders.length >= event.limit;
      debugPrint('📄 [BLOC] hasMore: $hasMore');

      if (state is AdminLoaded) {
        final currentState = state as AdminLoaded;

        // 🔥 CORRECCIÓN: Acumular órdenes correctamente
        List<AdminOrder> updatedOrders;

        if (event.page == 1) {
          // Si es página 1, reemplazamos (primera carga)
          updatedOrders = orders;
          debugPrint('🔄 [BLOC] Primera página: reemplazando órdenes');
        } else {
          // Si es página > 1, acumulamos
          updatedOrders = [...currentState.orders, ...orders];
          debugPrint('🔄 [BLOC] Acumulando órdenes: ${updatedOrders.length}');
        }

        emit(AdminLoaded(
          stats: currentState.stats,
          orders: updatedOrders,
          users: currentState.users,
          hasMoreOrders: hasMore,
        ));
      } else {
        // Estado inicial
        emit(AdminLoaded(
          stats: AdminStats.empty(),
          orders: orders,
          users: [],
          hasMoreOrders: hasMore,
        ));
      }
    } catch (e) {
      debugPrint('❌ [BLOC] Error cargando órdenes: $e');
      emit(AdminError(message: e.toString()));
    }
  }

  Future<void> _onLoadUsers(
    LoadUsers event,
    Emitter<AdminState> emit,
  ) async {
    debugPrint('🔄 [BLOC] Cargando usuarios - Página: ${event.page}');

    try {
      final users = await _repository.getUsers(
        page: event.page,
        limit: event.limit,
      );
      debugPrint('✅ [BLOC] Usuarios recibidos: ${users.length}');

      final hasMore = users.length >= event.limit;

      if (state is AdminLoaded) {
        final currentState = state as AdminLoaded;

        final List<dynamic> updatedUsers =
            event.page == 1 ? users : [...currentState.users, ...users];

        emit(AdminLoaded(
          stats: currentState.stats,
          orders: currentState.orders,
          users: updatedUsers,
          hasMoreOrders: currentState.hasMoreOrders,
          hasMoreUsers: hasMore,
        ));

        debugPrint('✅ [BLOC] Usuarios en estado AHORA: ${updatedUsers.length}');
      } else {
        emit(AdminLoaded(
          stats: AdminStats.empty(),
          orders: [],
          users: users,
          hasMoreUsers: hasMore,
        ));
        debugPrint('✅ [BLOC] Nuevo estado con ${users.length} usuarios');
      }
    } catch (e) {
      debugPrint('❌ [BLOC] Error: $e');
      emit(AdminError(message: e.toString()));
    }
  }

  Future<void> _onRefreshData(
    RefreshAdminData event,
    Emitter<AdminState> emit,
  ) async {
    add(LoadAdminDashboard());
  }
}
