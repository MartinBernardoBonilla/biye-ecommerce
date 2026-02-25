import 'package:equatable/equatable.dart';
import 'package:biye/features/cart/domain/entities/cart_item.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class AddToCart extends CartEvent {
  final CartItem item;
  const AddToCart(this.item);

  @override
  List<Object?> get props => [item];
}

class RemoveFromCart extends CartEvent {
  final String itemId;
  const RemoveFromCart(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class ClearCart extends CartEvent {
  const ClearCart();
}

class UpdateQuantity extends CartEvent {
  final String itemId;
  final int quantity;
  const UpdateQuantity(this.itemId, this.quantity);

  @override
  List<Object?> get props => [itemId, quantity];
}

class StartCheckoutWithQR extends CartEvent {
  const StartCheckoutWithQR();
}

// Opcional: Evento para cuando el QR expire
class QrExpired extends CartEvent {
  const QrExpired();

  @override
  List<Object> get props => [];
}

// Opcional: Evento para actualizar el estado del pago
class CheckQrPaymentStatus extends CartEvent {
  final String paymentId;
  const CheckQrPaymentStatus(this.paymentId);

  @override
  List<Object> get props => [paymentId];
}

class StartCheckout extends CartEvent {}

class CartPaymentConfirmed extends CartEvent {}
