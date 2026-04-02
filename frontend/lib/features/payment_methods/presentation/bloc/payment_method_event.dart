import 'package:equatable/equatable.dart';

abstract class PaymentMethodEvent extends Equatable {
  const PaymentMethodEvent();
  @override
  List<Object?> get props => [];
}

class LoadPaymentMethods extends PaymentMethodEvent {}

class AddCard extends PaymentMethodEvent {
  final String lastFourDigits;
  final String brand;
  final String expirationMonth;
  final String expirationYear;
  final String cardholderName;
  final bool isDefault;

  const AddCard({
    required this.lastFourDigits,
    required this.brand,
    required this.expirationMonth,
    required this.expirationYear,
    required this.cardholderName,
    this.isDefault = false,
  });

  @override
  List<Object?> get props => [
        lastFourDigits,
        brand,
        expirationMonth,
        expirationYear,
        cardholderName,
        isDefault
      ];
}

class DeletePaymentMethod extends PaymentMethodEvent {
  final String id;
  const DeletePaymentMethod({required this.id});
  @override
  List<Object?> get props => [id];
}

class SetDefaultPaymentMethod extends PaymentMethodEvent {
  final String id;
  const SetDefaultPaymentMethod({required this.id});
  @override
  List<Object?> get props => [id];
}

class ClearPaymentMethodState extends PaymentMethodEvent {}
