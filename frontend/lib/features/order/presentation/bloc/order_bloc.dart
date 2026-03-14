// lib/features/order/presentation/bloc/order_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:biye/features/order/domain/entities/order_entity.dart';
import 'package:biye/features/order/domain/repositories/order_repository.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository _repository;

  OrderBloc({required OrderRepository repository})
      : _repository = repository,
        super(OrderInitial()) {
    on<LoadMyOrders>(_onLoadMyOrders);
    on<LoadOrderDetails>(_onLoadOrderDetails);
  }

  Future<void> _onLoadMyOrders(
    LoadMyOrders event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      final orders = await _repository.getMyOrders();
      emit(OrderLoaded(orders: orders));
    } catch (e) {
      emit(OrderError(message: e.toString()));
    }
  }

  Future<void> _onLoadOrderDetails(
    LoadOrderDetails event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      final order = await _repository.getOrderById(event.orderId);
      emit(OrderDetailLoaded(order: order));
    } catch (e) {
      emit(OrderError(message: e.toString()));
    }
  }
}
