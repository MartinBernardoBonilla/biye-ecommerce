part of 'order_bloc.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderLoaded extends OrderState {
  final List<OrderEntity> orders;

  const OrderLoaded({required this.orders});

  @override
  List<Object> get props => [orders];
}

class OrderDetailLoaded extends OrderState {
  final OrderEntity order;

  const OrderDetailLoaded({required this.order});

  @override
  List<Object> get props => [order];
}

class OrderError extends OrderState {
  final String message;

  const OrderError({required this.message});

  @override
  List<Object> get props => [message];
}
