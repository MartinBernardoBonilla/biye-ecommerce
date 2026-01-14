import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:biye/features/cart/domain/entities/cart_item.dart';
import 'cart_event.dart';
import 'cart_state.dart';
import 'package:biye/features/payment/data/services/mercadopago_service.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final MercadoPagoService mercadoPagoService;

  CartBloc({
    required this.mercadoPagoService,
  }) : super(CartState.initial()) {
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<ClearCart>(_onClearCart);
    on<UpdateQuantity>(_onUpdateQuantity);
    on<StartCheckout>(_onStartCheckout);
  }

  void _onAddToCart(AddToCart event, Emitter<CartState> emit) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((e) => e.id == event.item.id);

    if (index >= 0) {
      items[index] = items[index].copyWith(quantity: items[index].quantity + 1);
    } else {
      items.add(event.item.copyWith(quantity: 1));
    }

    _emitTotals(items, emit);
  }

  void _onRemoveFromCart(RemoveFromCart event, Emitter<CartState> emit) {
    final items = state.items.where((e) => e.id != event.itemId).toList();
    _emitTotals(items, emit);
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    _emitTotals([], emit);
  }

  void _onUpdateQuantity(UpdateQuantity event, Emitter<CartState> emit) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((e) => e.id == event.itemId);

    if (index >= 0) {
      if (event.quantity > 0) {
        items[index] = items[index].copyWith(quantity: event.quantity);
      } else {
        items.removeAt(index);
      }
    }

    _emitTotals(items, emit);
  }

  Future<void> _onStartCheckout(
    StartCheckout event,
    Emitter<CartState> emit,
  ) async {
    if (state.items.isEmpty) {
      emit(
        CheckoutErrorState(
          state: state,
          message: 'El carrito está vacío',
        ),
      );
      return;
    }

    emit(CheckoutLoadingState(state: state));

    try {
      final initPoint = await mercadoPagoService.createPaymentPreference(
        event.orderId,
      );

      emit(
        CheckoutSuccessState(
          state: state,
          initPoint: initPoint,
        ),
      );
    } catch (e) {
      emit(
        CheckoutErrorState(
          state: state,
          message: e.toString(),
        ),
      );
    }
  }

  void _emitTotals(List<CartItem> items, Emitter<CartState> emit) {
    final total = items.fold(
      0.0,
      (sum, item) => sum + item.price * item.quantity,
    );

    emit(
      state.copyWith(
        items: items,
        total: total,
        isCheckoutLoading: false,
        checkoutError: null,
        initPoint: null,
      ),
    );
  }
}
