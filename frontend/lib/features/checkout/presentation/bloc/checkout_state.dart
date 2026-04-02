// lib/features/checkout/presentation/bloc/checkout_state.dart

import 'package:equatable/equatable.dart';
import 'package:biye/features/cart/domain/entities/cart_item.dart';
import 'package:biye/features/address/domain/entities/address.dart';
import 'package:biye/features/payment_methods/domain/entities/payment_method.dart';

abstract class CheckoutState extends Equatable {
  const CheckoutState();
  @override
  List<Object?> get props => [];
}

class CheckoutInitial extends CheckoutState {}

class CheckoutLoading extends CheckoutState {}

class CheckoutLoaded extends CheckoutState {
  final List<CartItem> items;
  final List<Address> addresses;
  final List<PaymentMethod> paymentMethods;
  final Address? selectedAddress;
  final PaymentMethod? selectedPaymentMethod;
  final double subtotal;
  final double shippingCost;
  final double tax;
  final double total;

  const CheckoutLoaded({
    required this.items,
    required this.addresses,
    required this.paymentMethods,
    this.selectedAddress,
    this.selectedPaymentMethod,
    required this.subtotal,
    required this.shippingCost,
    required this.tax,
    required this.total,
  });

  CheckoutLoaded copyWith({
    List<CartItem>? items,
    List<Address>? addresses,
    List<PaymentMethod>? paymentMethods,
    Address? selectedAddress,
    PaymentMethod? selectedPaymentMethod,
    double? subtotal,
    double? shippingCost,
    double? tax,
    double? total,
  }) {
    return CheckoutLoaded(
      items: items ?? this.items,
      addresses: addresses ?? this.addresses,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      selectedPaymentMethod:
          selectedPaymentMethod ?? this.selectedPaymentMethod,
      subtotal: subtotal ?? this.subtotal,
      shippingCost: shippingCost ?? this.shippingCost,
      tax: tax ?? this.tax,
      total: total ?? this.total,
    );
  }

  bool get canProceed =>
      selectedAddress != null && selectedPaymentMethod != null;

  @override
  List<Object?> get props => [
        items,
        addresses,
        paymentMethods,
        selectedAddress,
        selectedPaymentMethod,
        subtotal,
        shippingCost,
        tax,
        total
      ];
}

class CheckoutSuccess extends CheckoutState {
  final String orderId;
  final String? paymentUrl;
  const CheckoutSuccess({required this.orderId, this.paymentUrl});
  @override
  List<Object?> get props => [orderId, paymentUrl];
}

class CheckoutError extends CheckoutState {
  final String message;
  const CheckoutError({required this.message});
  @override
  List<Object?> get props => [message];
}
