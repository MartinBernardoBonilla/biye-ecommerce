// lib/features/admin/presentation/bloc/admin_event.dart
part of 'admin_bloc.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object> get props => [];
}

class LoadAdminDashboard extends AdminEvent {}

class LoadOrders extends AdminEvent {
  final int page;
  final int limit;

  const LoadOrders({this.page = 1, this.limit = 20});

  @override
  List<Object> get props => [page, limit];
}

class LoadUsers extends AdminEvent {
  final int page;
  final int limit;

  const LoadUsers({this.page = 1, this.limit = 20});

  @override
  List<Object> get props => [page, limit];
}

class RefreshAdminData extends AdminEvent {}
