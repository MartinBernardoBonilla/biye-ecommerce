// lib/features/admin/presentation/bloc/admin_state.dart
part of 'admin_bloc.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminLoaded extends AdminState {
  final AdminStats stats;
  final List<AdminOrder> orders;
  final List<dynamic> users;
  final bool hasMoreOrders;
  final bool hasMoreUsers;

  const AdminLoaded({
    required this.stats,
    this.orders = const [],
    this.users = const [],
    this.hasMoreOrders = false,
    this.hasMoreUsers = false,
  });

  @override
  List<Object> get props => [stats, orders, users, hasMoreOrders, hasMoreUsers];
}

class AdminError extends AdminState {
  final String message;

  const AdminError({required this.message});

  @override
  List<Object> get props => [message];
}
