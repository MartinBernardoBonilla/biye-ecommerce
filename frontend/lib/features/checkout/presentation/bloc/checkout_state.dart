// lib/features/checkout/presentation/bloc/checkout_state.dart

import 'package:equatable/equatable.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../../address/domain/entities/address.dart';
import '../../../payment_methods/domain/entities/payment_method.dart';

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
  final String? selectedPaymentMethodId;
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
    this.selectedPaymentMethodId,
    required this.subtotal,
    required this.shippingCost,
    required this.tax,
    required this.total,
  });

  bool get canProceed =>
      selectedAddress != null && selectedPaymentMethod != null;

  CheckoutLoaded copyWith({
    List<CartItem>? items,
    List<Address>? addresses,
    List<PaymentMethod>? paymentMethods,
    Address? selectedAddress,
    PaymentMethod? selectedPaymentMethod,
    String? selectedPaymentMethodId,
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
      selectedPaymentMethodId:
          selectedPaymentMethodId ?? this.selectedPaymentMethodId,
      subtotal: subtotal ?? this.subtotal,
      shippingCost: shippingCost ?? this.shippingCost,
      tax: tax ?? this.tax,
      total: total ?? this.total,
    );
  }

  @override
  List<Object?> get props => [
        items,
        addresses,
        paymentMethods,
        selectedAddress,
        selectedPaymentMethod,
        selectedPaymentMethodId,
        subtotal,
        shippingCost,
        tax,
        total
      ];
}

class CheckoutOrderCreated extends CheckoutState {
  final String orderId;
  final String qrData;
  final String? qrImageBase64; // ✅ AGREGAR
  final String? paymentMethodType;

  const CheckoutOrderCreated({
    required this.orderId,
    required this.qrData,
    this.qrImageBase64, // ✅ AGREGAR
    this.paymentMethodType,
  });

  @override
  List<Object?> get props =>
      [orderId, qrData, qrImageBase64, paymentMethodType];
}

class CheckoutPaymentConfirmed extends CheckoutState {
  final String orderId;
  const CheckoutPaymentConfirmed({required this.orderId});
  @override
  List<Object?> get props => [orderId];
}

class CheckoutError extends CheckoutState {
  final String message;
  const CheckoutError({required this.message});
  @override
  List<Object?> get props => [message];
}
