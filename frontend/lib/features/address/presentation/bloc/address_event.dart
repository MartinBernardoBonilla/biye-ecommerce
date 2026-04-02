import 'package:equatable/equatable.dart';
import 'package:biye/features/address/domain/entities/address.dart';

abstract class AddressEvent extends Equatable {
  const AddressEvent();

  @override
  List<Object?> get props => [];
}

class LoadAddresses extends AddressEvent {}

class LoadAddressById extends AddressEvent {
  final String id;
  const LoadAddressById({required this.id});
  @override
  List<Object?> get props => [id];
}

class CreateAddress extends AddressEvent {
  final Address address;
  const CreateAddress({required this.address});
  @override
  List<Object?> get props => [address];
}

class UpdateAddress extends AddressEvent {
  final Address address;
  const UpdateAddress({required this.address});
  @override
  List<Object?> get props => [address];
}

class DeleteAddress extends AddressEvent {
  final String id;
  const DeleteAddress({required this.id});
  @override
  List<Object?> get props => [id];
}

class SetDefaultAddress extends AddressEvent {
  final String id;
  const SetDefaultAddress({required this.id});
  @override
  List<Object?> get props => [id];
}

class ClearAddressState extends AddressEvent {}
