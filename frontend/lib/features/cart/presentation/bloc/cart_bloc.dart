import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:biye/features/cart/domain/entities/cart_item.dart';
import 'package:biye/features/cart/presentation/bloc/cart_event.dart';
import 'package:biye/features/cart/presentation/bloc/cart_state.dart';
// Importamos el nuevo servicio de Mercado Pago
import 'package:biye/features/payment/data/services/mercadopago_service.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  // Inyectamos el servicio (puede ser mock o real)
  final MercadoPagoService _mercadoPagoService;

  CartBloc({MercadoPagoService? mercadoPagoService})
    : _mercadoPagoService = mercadoPagoService ?? MercadoPagoService(),
      super(CartState.initial()) {
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<ClearCart>(_onClearCart);
    on<UpdateQuantity>(_onUpdateQuantity);
    // Manejador del nuevo evento de checkout
    on<StartCheckout>(_onStartCheckout);

    // Inicializa la carga si tienes persistencia (simulamos un estado inicial limpio)
    //_loadCart();
  }

  void _onAddToCart(AddToCart event, Emitter<CartState> emit) {
    final List<CartItem> newItems = List.from(state.items);
    final int existingIndex = newItems.indexWhere(
      (item) => item.id == event.item.id,
    );

    if (existingIndex >= 0) {
      // Si existe, incrementa la cantidad
      final existingItem = newItems[existingIndex];
      newItems[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + 1,
      );
    } else {
      // Si es nuevo, añade el artículo
      newItems.add(event.item.copyWith(quantity: 1));
    }

    _calculateTotalAndEmit(newItems, emit);
  }

  void _onRemoveFromCart(RemoveFromCart event, Emitter<CartState> emit) {
    final List<CartItem> newItems = state.items
        .where((item) => item.id != event.itemId)
        .toList();
    _calculateTotalAndEmit(newItems, emit);
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    _calculateTotalAndEmit([], emit);
  }

  void _onUpdateQuantity(UpdateQuantity event, Emitter<CartState> emit) {
    final List<CartItem> newItems = List.from(state.items);
    final int index = newItems.indexWhere((item) => item.id == event.itemId);

    if (index >= 0) {
      if (event.quantity > 0) {
        newItems[index] = newItems[index].copyWith(quantity: event.quantity);
      } else {
        // Eliminar si la cantidad es 0
        newItems.removeAt(index);
      }
    }
    _calculateTotalAndEmit(newItems, emit);
  }

  // Nuevo Manejador de Checkout
  Future<void> _onStartCheckout(
    StartCheckout event,
    Emitter<CartState> emit,
  ) async {
    if (state.items.isEmpty) {
      emit(CheckoutErrorState(state: state, message: 'El carrito está vacío.'));
      return;
    }

    emit(CheckoutLoadingState(state: state));

    try {
      // 1. Llamar al backend para crear la preferencia
      final preferenceId = await _mercadoPagoService.createPreference(
        state.items,
        state.total,
      );

      // 2. Emitir éxito con el ID de preferencia
      emit(CheckoutSuccessState(state: state, newPreferenceId: preferenceId));
    } catch (e) {
      // 3. Manejar error
      emit(
        CheckoutErrorState(
          state: state,
          message:
              'Fallo la generación de la preferencia de pago: ${e.toString()}',
        ),
      );
    }
  }

  // Función auxiliar para calcular el total
  void _calculateTotalAndEmit(List<CartItem> items, Emitter<CartState> emit) {
    final double newTotal = items.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    emit(
      state.copyWith(
        items: items,
        total: newTotal,
        // Resetear estados de checkout al modificar el carrito
        preferenceId: null,
        isCheckoutLoading: false,
        checkoutError: null,
      ),
    );
  }
}
