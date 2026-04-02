// lib/features/order/presentation/bloc/order_bloc.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:biye/features/order/domain/entities/order.dart'; // ✅ Cambiar a order.dart
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
      final orders =
          await _repository.getUserOrders(); // ✅ Cambiar a getUserOrders
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
      final order =
          await _repository.getOrder(event.orderId); // ✅ Cambiar a getOrder
      if (order != null) {
        emit(OrderDetailLoaded(order: order));
      } else {
        emit(OrderError(message: 'Orden no encontrada'));
      }
    } catch (e) {
      emit(OrderError(message: e.toString()));
    }
  }
}
