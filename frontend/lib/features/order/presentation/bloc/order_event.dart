part of 'order_bloc.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object> get props => [];
}

class LoadMyOrders extends OrderEvent {}

class LoadOrderDetails extends OrderEvent {
  final String orderId;

  const LoadOrderDetails({required this.orderId});

  @override
  List<Object> get props => [orderId];
}
