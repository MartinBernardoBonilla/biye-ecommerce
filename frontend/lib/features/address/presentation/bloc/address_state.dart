import 'package:biye/features/address/domain/entities/address.dart';
import 'package:equatable/equatable.dart';

abstract class AddressState extends Equatable {
  const AddressState();
  @override
  List<Object?> get props => [];
}

class AddressInitial extends AddressState {}

class AddressLoading extends AddressState {}

class AddressesLoaded extends AddressState {
  final List<Address> addresses;
  const AddressesLoaded({required this.addresses});
  @override
  List<Object?> get props => [addresses];
}

class AddressLoaded extends AddressState {
  final Address address;
  const AddressLoaded({required this.address});
  @override
  List<Object?> get props => [address];
}

class AddressSuccess extends AddressState {
  final String message;
  const AddressSuccess({required this.message});
  @override
  List<Object?> get props => [message];
}

class AddressError extends AddressState {
  final String message;
  const AddressError({required this.message});
  @override
  List<Object?> get props => [message];
}

class AddressFormState extends AddressState {
  final bool isLoading;
  final String? error;
  final Address? address;
  const AddressFormState({this.isLoading = false, this.error, this.address});

  AddressFormState copyWith(
      {bool? isLoading, String? error, Address? address}) {
    return AddressFormState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      address: address ?? this.address,
    );
  }

  @override
  List<Object?> get props => [isLoading, error, address];
}
