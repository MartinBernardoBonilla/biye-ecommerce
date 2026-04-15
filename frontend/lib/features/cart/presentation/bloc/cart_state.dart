import 'package:equatable/equatable.dart';
import 'package:biye/features/cart/domain/entities/cart_item.dart';

class CartState extends Equatable {
  final List<CartItem> items;
  final double total;

  const CartState({
    this.items = const [],
    this.total = 0.0,
  });

  factory CartState.initial() => const CartState();

  CartState copyWith({
    List<CartItem>? items,
    double? total,
  }) {
    return CartState(
      items: items ?? this.items,
      total: total ?? this.total,
    );
  }

  @override
  List<Object?> get props => [items, total];
}
