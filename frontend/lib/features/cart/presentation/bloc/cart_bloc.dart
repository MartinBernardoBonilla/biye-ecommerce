import 'package:flutter_bloc/flutter_bloc.dart';
import 'cart_event.dart';
import 'cart_state.dart';
import '../../domain/entities/cart_item.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartState.initial()) {
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateQuantity>(_onUpdateQuantity);
    on<ClearCart>(_onClearCart);
  }

  void _onAddToCart(AddToCart event, Emitter<CartState> emit) {
    final newItems = List<CartItem>.from(state.items);
    final index = newItems.indexWhere((item) => item.id == event.item.id);
    
    if (index != -1) {
      final current = newItems[index];
      newItems[index] = current.copyWith(
        quantity: current.quantity + event.item.quantity,
      );
    } else {
      newItems.add(event.item);
    }
    
    final newTotal = newItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    emit(state.copyWith(items: newItems, total: newTotal));
  }

  void _onRemoveFromCart(RemoveFromCart event, Emitter<CartState> emit) {
    final newItems = state.items.where((item) => item.id != event.productId).toList();
    final newTotal = newItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    emit(state.copyWith(items: newItems, total: newTotal));
  }

  void _onUpdateQuantity(UpdateQuantity event, Emitter<CartState> emit) {
    final newItems = state.items.map((item) {
      if (item.id == event.productId) {
        return item.copyWith(quantity: event.quantity);
      }
      return item;
    }).toList();
    
    final newTotal = newItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    emit(state.copyWith(items: newItems, total: newTotal));
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    emit(CartState.initial());
  }
}
