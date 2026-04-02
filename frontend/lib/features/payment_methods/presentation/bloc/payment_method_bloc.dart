import 'package:biye/features/payment_methods/data/repositories/payment_method_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'payment_method_event.dart';
import 'payment_method_state.dart';

class PaymentMethodBloc extends Bloc<PaymentMethodEvent, PaymentMethodState> {
  final PaymentMethodRepository _repository;

  PaymentMethodBloc({required PaymentMethodRepository repository})
      : _repository = repository,
        super(PaymentMethodInitial()) {
    on<LoadPaymentMethods>(_onLoadPaymentMethods);
    on<AddCard>(_onAddCard);
    on<DeletePaymentMethod>(_onDeletePaymentMethod);
    on<SetDefaultPaymentMethod>(_onSetDefaultPaymentMethod);
    on<ClearPaymentMethodState>(_onClearState);
  }

  Future<void> _onLoadPaymentMethods(
    LoadPaymentMethods event,
    Emitter<PaymentMethodState> emit,
  ) async {
    emit(PaymentMethodLoading());
    try {
      final methods = await _repository.getPaymentMethods();
      emit(PaymentMethodsLoaded(methods: methods));
    } catch (e) {
      emit(PaymentMethodError(message: 'Error al cargar métodos de pago: $e'));
    }
  }

  Future<void> _onAddCard(
    AddCard event,
    Emitter<PaymentMethodState> emit,
  ) async {
    emit(PaymentMethodFormState(isLoading: true));
    try {
      final method = await _repository.addCard(
        lastFourDigits: event.lastFourDigits,
        brand: event.brand,
        expirationMonth: event.expirationMonth,
        expirationYear: event.expirationYear,
        cardholderName: event.cardholderName,
        isDefault: event.isDefault,
      );

      if (method != null) {
        emit(PaymentMethodSuccess(message: 'Tarjeta agregada exitosamente'));
        add(LoadPaymentMethods());
      } else {
        emit(PaymentMethodFormState(
          isLoading: false,
          error: 'Error al agregar tarjeta',
        ));
      }
    } catch (e) {
      emit(PaymentMethodFormState(
        isLoading: false,
        error: 'Error al agregar tarjeta: $e',
      ));
    }
  }

  Future<void> _onDeletePaymentMethod(
    DeletePaymentMethod event,
    Emitter<PaymentMethodState> emit,
  ) async {
    emit(PaymentMethodLoading());
    try {
      final success = await _repository.deletePaymentMethod(event.id);
      if (success) {
        emit(PaymentMethodSuccess(message: 'Método de pago eliminado'));
        add(LoadPaymentMethods());
      } else {
        emit(PaymentMethodError(message: 'Error al eliminar método de pago'));
      }
    } catch (e) {
      emit(PaymentMethodError(message: 'Error al eliminar método de pago: $e'));
    }
  }

  Future<void> _onSetDefaultPaymentMethod(
    SetDefaultPaymentMethod event,
    Emitter<PaymentMethodState> emit,
  ) async {
    emit(PaymentMethodLoading());
    try {
      final method = await _repository.setDefaultPaymentMethod(event.id);
      if (method != null) {
        emit(
            PaymentMethodSuccess(message: 'Método predeterminado actualizado'));
        add(LoadPaymentMethods());
      } else {
        emit(PaymentMethodError(
            message: 'Error al establecer método predeterminado'));
      }
    } catch (e) {
      emit(PaymentMethodError(
          message: 'Error al establecer método predeterminado: $e'));
    }
  }

  void _onClearState(
    ClearPaymentMethodState event,
    Emitter<PaymentMethodState> emit,
  ) {
    emit(PaymentMethodInitial());
  }
}
