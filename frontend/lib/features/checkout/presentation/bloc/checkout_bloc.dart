// lib/features/checkout/presentation/bloc/checkout_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:biye/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:biye/features/cart/presentation/bloc/cart_event.dart';
import 'package:biye/features/address/presentation/bloc/address_bloc.dart';
import 'package:biye/features/address/presentation/bloc/address_event.dart';
import 'package:biye/features/payment_methods/presentation/bloc/payment_method_bloc.dart';
import 'package:biye/features/payment_methods/presentation/bloc/payment_method_event.dart';
import 'checkout_event.dart';
import 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final CartBloc _cartBloc;
  final AddressBloc _addressBloc;
  final PaymentMethodBloc _paymentMethodBloc;

  CheckoutBloc({
    required CartBloc cartBloc,
    required AddressBloc addressBloc,
    required PaymentMethodBloc paymentMethodBloc,
  })  : _cartBloc = cartBloc,
        _addressBloc = addressBloc,
        _paymentMethodBloc = paymentMethodBloc,
        super(CheckoutInitial()) {
    on<LoadCheckoutData>(_onLoadCheckoutData);
    on<SelectAddress>(_onSelectAddress);
    on<SelectPaymentMethod>(_onSelectPaymentMethod);
    on<ConfirmOrder>(_onConfirmOrder);
  }

  Future<void> _onLoadCheckoutData(
    LoadCheckoutData event,
    Emitter<CheckoutState> emit,
  ) async {
    emit(CheckoutLoading());

    _addressBloc.add(LoadAddresses());
    _paymentMethodBloc.add(LoadPaymentMethods());

    final cartState = _cartBloc.state;
    // ✅ CartState tiene items y total
    final items = cartState.items;
    final subtotal = cartState.total;
    final shippingCost = 0.0;
    final tax = subtotal * 0.21;
    final total = subtotal + shippingCost + tax;

    if (items.isEmpty) {
      emit(CheckoutError(message: 'No hay productos en el carrito'));
      return;
    }

    emit(CheckoutLoaded(
      items: items,
      addresses: [],
      paymentMethods: [],
      subtotal: subtotal,
      shippingCost: shippingCost,
      tax: tax,
      total: total,
    ));
  }

  Future<void> _onSelectAddress(
    SelectAddress event,
    Emitter<CheckoutState> emit,
  ) async {
    if (state is CheckoutLoaded) {
      final current = state as CheckoutLoaded;
      emit(current.copyWith(selectedAddress: event.address));
    }
  }

  Future<void> _onSelectPaymentMethod(
    SelectPaymentMethod event,
    Emitter<CheckoutState> emit,
  ) async {
    if (state is CheckoutLoaded) {
      final current = state as CheckoutLoaded;
      emit(current.copyWith(selectedPaymentMethod: event.method));
    }
  }

  Future<void> _onConfirmOrder(
    ConfirmOrder event,
    Emitter<CheckoutState> emit,
  ) async {
    if (state is! CheckoutLoaded) return;

    final current = state as CheckoutLoaded;

    if (!current.canProceed) {
      emit(CheckoutError(message: 'Selecciona dirección y método de pago'));
      return;
    }

    emit(CheckoutLoading());

    // Simular éxito por ahora
    await Future.delayed(const Duration(seconds: 1));

    // Limpiar carrito
    _cartBloc.add(ClearCart());

    emit(CheckoutSuccess(
      orderId: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      paymentUrl: null,
    ));
  }
}
