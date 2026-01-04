import 'package:equatable/equatable.dart';
import 'package:biye/features/cart/domain/entities/cart_item.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

class AddToCart extends CartEvent {
  final CartItem item;
  const AddToCart(this.item);

  @override
  List<Object> get props => [item];
}

class RemoveFromCart extends CartEvent {
  final String itemId;
  const RemoveFromCart(this.itemId);

  @override
  List<Object> get props => [itemId];
}

class ClearCart extends CartEvent {}

// Nuevo Evento para iniciar el flujo de pago con Mercado Pago
class StartCheckout extends CartEvent {
  const StartCheckout();
}

class UpdateQuantity extends CartEvent {
  final String itemId;
  final int quantity;
  const UpdateQuantity(this.itemId, this.quantity);

  @override
  List<Object> get props => [itemId, quantity];
}
