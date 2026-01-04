import 'package:equatable/equatable.dart';
import 'package:biye/features/cart/domain/entities/cart_item.dart';

class CartState extends Equatable {
  final List<CartItem> items;
  final double total;
  final bool isLoading;
  final String? preferenceId;
  final bool isCheckoutLoading;
  final String? checkoutError;

  // El constructor principal puede seguir siendo const
  const CartState({
    this.items = const [],
    this.total = 0.0,
    this.isLoading = false,
    this.preferenceId,
    this.isCheckoutLoading = false,
    this.checkoutError,
  });

  factory CartState.initial() {
    return const CartState();
  }

  CartState copyWith({
    List<CartItem>? items,
    double? total,
    bool? isLoading,
    String? preferenceId,
    bool? isCheckoutLoading,
    String? checkoutError,
  }) {
    return CartState(
      items: items ?? this.items,
      total: total ?? this.total,
      isLoading: isLoading ?? this.isLoading,
      // Usamos 'null' para resetear el ID después del pago (si no se proporciona)
      preferenceId: preferenceId,
      isCheckoutLoading: isCheckoutLoading ?? this.isCheckoutLoading,
      checkoutError: checkoutError,
    );
  }

  @override
  List<Object?> get props => [
    items,
    total,
    isLoading,
    preferenceId,
    isCheckoutLoading,
    checkoutError,
  ];
}

class CartInitial extends CartState {}

// [CORRECCIÓN]: Eliminamos 'const'
class CartLoading extends CartState {
  CartLoading({required CartState state})
    : super(items: state.items, total: state.total, isLoading: true);
  @override
  List<Object?> get props => [items, total, true];
}

// [CORRECCIÓN]: Eliminamos 'const'
class CartLoaded extends CartState {
  const CartLoaded({required super.items, required super.total})
    : super(isLoading: false);
  @override
  List<Object?> get props => [items, total, false];
}

// Nuevo Estado de Checkout

// [CORRECCIÓN]: Eliminamos 'const'
class CheckoutLoadingState extends CartState {
  CheckoutLoadingState({required CartState state})
    : super(items: state.items, total: state.total, isCheckoutLoading: true);
}

// [CORRECCIÓN]: Eliminamos 'const'
class CheckoutSuccessState extends CartState {
  final String newPreferenceId;
  CheckoutSuccessState({
    required CartState state,
    required this.newPreferenceId,
  }) : super(
         items: state.items,
         total: state.total,
         isCheckoutLoading: false,
         preferenceId: newPreferenceId,
       );
  @override
  List<Object?> get props => [...super.props, newPreferenceId];
}

// [CORRECCIÓN]: Eliminamos 'const'
class CheckoutErrorState extends CartState {
  final String message;
  CheckoutErrorState({required CartState state, required this.message})
    : super(
        items: state.items,
        total: state.total,
        isCheckoutLoading: false,
        checkoutError: message,
      );
  @override
  List<Object?> get props => [...super.props, message];
}
