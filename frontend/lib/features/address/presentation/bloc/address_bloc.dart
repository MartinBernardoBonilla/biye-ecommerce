import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:biye/features/address/presentation/bloc/address_event.dart';
import 'package:biye/features/address/presentation/bloc/address_state.dart';
import 'package:biye/features/address/data/repositories/address_repository.dart';
// ✅ NO importar address.dart aquí, se usa a través de address_event y address_state

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final AddressRepository _repository;

  AddressBloc({required AddressRepository repository})
      : _repository = repository,
        super(AddressInitial()) {
    on<LoadAddresses>(_onLoadAddresses);
    on<LoadAddressById>(_onLoadAddressById);
    on<CreateAddress>(_onCreateAddress);
    on<UpdateAddress>(_onUpdateAddress);
    on<DeleteAddress>(_onDeleteAddress);
    on<SetDefaultAddress>(_onSetDefaultAddress);
    on<ClearAddressState>(_onClearAddressState);
  }

  Future<void> _onLoadAddresses(
    LoadAddresses event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());
    try {
      final addresses = await _repository.getAddresses();
      emit(AddressesLoaded(addresses: addresses));
    } catch (e) {
      emit(AddressError(message: 'Error al cargar direcciones: $e'));
    }
  }

  Future<void> _onLoadAddressById(
    LoadAddressById event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());
    try {
      final address = await _repository.getAddressById(event.id);
      if (address != null) {
        emit(AddressLoaded(address: address));
      } else {
        emit(AddressError(message: 'Dirección no encontrada'));
      }
    } catch (e) {
      emit(AddressError(message: 'Error al cargar dirección: $e'));
    }
  }

  Future<void> _onCreateAddress(
    CreateAddress event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressFormState(isLoading: true));
    try {
      final address = await _repository.createAddress(event.address);
      if (address != null) {
        emit(AddressSuccess(message: 'Dirección creada exitosamente'));
        add(LoadAddresses());
      } else {
        emit(AddressFormState(
          isLoading: false,
          error: 'Error al crear dirección',
        ));
      }
    } catch (e) {
      emit(AddressFormState(
        isLoading: false,
        error: 'Error al crear dirección: $e',
      ));
    }
  }

  Future<void> _onUpdateAddress(
    UpdateAddress event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressFormState(isLoading: true));
    try {
      final address = await _repository.updateAddress(event.address);
      if (address != null) {
        emit(AddressSuccess(message: 'Dirección actualizada exitosamente'));
        add(LoadAddresses());
      } else {
        emit(AddressFormState(
          isLoading: false,
          error: 'Error al actualizar dirección',
        ));
      }
    } catch (e) {
      emit(AddressFormState(
        isLoading: false,
        error: 'Error al actualizar dirección: $e',
      ));
    }
  }

  Future<void> _onDeleteAddress(
    DeleteAddress event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());
    try {
      final success = await _repository.deleteAddress(event.id);
      if (success) {
        emit(AddressSuccess(message: 'Dirección eliminada exitosamente'));
        add(LoadAddresses());
      } else {
        emit(AddressError(message: 'Error al eliminar dirección'));
      }
    } catch (e) {
      emit(AddressError(message: 'Error al eliminar dirección: $e'));
    }
  }

  Future<void> _onSetDefaultAddress(
    SetDefaultAddress event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());
    try {
      final address = await _repository.setDefaultAddress(event.id);
      if (address != null) {
        emit(AddressSuccess(message: 'Dirección predeterminada actualizada'));
        add(LoadAddresses());
      } else {
        emit(AddressError(
            message: 'Error al establecer dirección predeterminada'));
      }
    } catch (e) {
      emit(AddressError(
          message: 'Error al establecer dirección predeterminada: $e'));
    }
  }

  void _onClearAddressState(
    ClearAddressState event,
    Emitter<AddressState> emit,
  ) {
    emit(AddressInitial());
  }
}
