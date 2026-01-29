import 'package:equatable/equatable.dart';
import 'package:biye/features/cart/domain/entities/cart_item.dart';

class CartState extends Equatable {
  final List<CartItem> items;
  final double total;
  final bool isLoading;
  final String? orderId;

  // Checkout
  final bool isCheckoutLoading;
  final String? initPoint;
  final String? checkoutError;

  const CartState({
    this.items = const [],
    this.total = 0.0,
    this.isLoading = false,
    this.orderId,
    this.isCheckoutLoading = false,
    this.initPoint,
    this.checkoutError,
  });

  factory CartState.initial() => const CartState();

  CartState copyWith({
    List<CartItem>? items,
    double? total,
    bool? isLoading,
    String? orderId,
    bool? isCheckoutLoading,
    String? initPoint,
    String? checkoutError,
  }) {
    return CartState(
      items: items ?? this.items,
      total: total ?? this.total,
      isLoading: isLoading ?? this.isLoading,
      orderId: orderId ?? this.orderId,
      isCheckoutLoading: isCheckoutLoading ?? this.isCheckoutLoading,
      initPoint: initPoint,
      checkoutError: checkoutError,
    );
  }

  @override
  List<Object?> get props => [
        items,
        total,
        isLoading,
        orderId,
        isCheckoutLoading,
        initPoint,
        checkoutError,
      ];
}

/// =======================
/// Checkout States
/// =======================

class CheckoutLoadingState extends CartState {
  CheckoutLoadingState({required CartState state})
      : super(
          items: state.items,
          total: state.total,
          isCheckoutLoading: true,
        );
}

class CheckoutErrorState extends CartState {
  final String message;

  CheckoutErrorState({
    required CartState state,
    required this.message,
  }) : super(
          items: state.items,
          total: state.total,
          isCheckoutLoading: false,
          checkoutError: message,
        );

  @override
  List<Object?> get props => [...super.props, message];
}
