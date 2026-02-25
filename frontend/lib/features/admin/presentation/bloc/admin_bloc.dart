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
    // Si ya hay estado loaded, preservamos los usuarios
    final currentUsers =
        state is AdminLoaded ? (state as AdminLoaded).users : [];

    emit(AdminLoading());

    try {
      final stats = await _repository.getDashboardStats();
      final recentOrders = await _repository.getRecentOrders(limit: 5);

      emit(AdminLoaded(
        stats: stats,
        orders: recentOrders,
        users: currentUsers, // 👈 PRESERVAR USUARIOS
      ));
    } catch (e) {
      emit(AdminError(message: e.toString()));
    }
  }

  Future<void> _onLoadOrders(
    LoadOrders event,
    Emitter<AdminState> emit,
  ) async {
    if (state is! AdminLoaded) return;

    final currentState = state as AdminLoaded;
    emit(AdminLoading());

    try {
      final orders = await _repository.getOrders(
        page: event.page,
        limit: event.limit,
      );

      final hasMore = orders.length >= event.limit;

      emit(AdminLoaded(
        stats: currentState.stats,
        orders: [...currentState.orders, ...orders],
        hasMoreOrders: hasMore,
      ));
    } catch (e) {
      emit(AdminError(message: e.toString()));
    }
  }

  Future<void> _onLoadUsers(
    LoadUsers event,
    Emitter<AdminState> emit,
  ) async {
    debugPrint('🔄 [BLOC] Cargando usuarios - Página: ${event.page}');

    try {
      debugPrint('🔄 [BLOC] Llamando a repository.getUsers()');
      final users = await _repository.getUsers(
        page: event.page,
        limit: event.limit,
      );
      debugPrint('✅ [BLOC] Usuarios recibidos del repo: ${users.length}');

      final hasMore = users.length >= event.limit;

      if (state is AdminLoaded) {
        final currentState = state as AdminLoaded;
        debugPrint(
            '🔄 [BLOC] Estado actual tiene ${currentState.users.length} usuarios');

        emit(AdminLoaded(
          stats: currentState.stats,
          orders: currentState.orders,
          users: [...currentState.users, ...users],
          hasMoreUsers: hasMore,
        ));

        debugPrint(
            '✅ [BLOC] Nuevo estado con ${currentState.users.length + users.length} usuarios');
      } else {
        debugPrint('🔄 [BLOC] Creando nuevo estado AdminLoaded');
        emit(AdminLoaded(
          stats: AdminStats.empty(),
          orders: [],
          users: users,
          hasMoreUsers: hasMore,
        ));
      }
    } catch (e) {
      debugPrint('❌ [BLOC] Error cargando usuarios: $e');
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
