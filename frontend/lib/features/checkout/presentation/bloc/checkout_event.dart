// lib/features/checkout/presentation/bloc/checkout_event.dart

import 'package:equatable/equatable.dart';
import 'package:biye/features/address/domain/entities/address.dart';
import 'package:biye/features/payment_methods/domain/entities/payment_method.dart';

abstract class CheckoutEvent extends Equatable {
  const CheckoutEvent();
  @override
  List<Object?> get props => [];
}

class LoadCheckoutData extends CheckoutEvent {}

class SelectAddress extends CheckoutEvent {
  final Address address;
  const SelectAddress({required this.address});
  @override
  List<Object?> get props => [address];
}

class SelectPaymentMethod extends CheckoutEvent {
  final PaymentMethod method;
  const SelectPaymentMethod({required this.method});
  @override
  List<Object?> get props => [method];
}

class ConfirmOrder extends CheckoutEvent {}
