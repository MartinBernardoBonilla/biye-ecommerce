import 'package:biye/features/payment_methods/domain/entities/payment_method.dart';
import 'package:equatable/equatable.dart';

abstract class PaymentMethodState extends Equatable {
  const PaymentMethodState();
  @override
  List<Object?> get props => [];
}

class PaymentMethodInitial extends PaymentMethodState {}

class PaymentMethodLoading extends PaymentMethodState {}

class PaymentMethodsLoaded extends PaymentMethodState {
  final List<PaymentMethod> methods;
  const PaymentMethodsLoaded({required this.methods});
  @override
  List<Object?> get props => [methods];
}

class PaymentMethodSuccess extends PaymentMethodState {
  final String message;
  const PaymentMethodSuccess({required this.message});
  @override
  List<Object?> get props => [message];
}

class PaymentMethodError extends PaymentMethodState {
  final String message;
  const PaymentMethodError({required this.message});
  @override
  List<Object?> get props => [message];
}

class PaymentMethodFormState extends PaymentMethodState {
  final bool isLoading;
  final String? error;
  final PaymentMethod? method;
  const PaymentMethodFormState(
      {this.isLoading = false, this.error, this.method});

  PaymentMethodFormState copyWith(
      {bool? isLoading, String? error, PaymentMethod? method}) {
    return PaymentMethodFormState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      method: method ?? this.method,
    );
  }

  @override
  List<Object?> get props => [isLoading, error, method];
}
