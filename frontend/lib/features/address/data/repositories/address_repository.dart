import 'package:biye/core/network/api_client.dart';
import '../../domain/entities/address.dart';

class AddressRepository {
  final ApiClient _apiClient;

  AddressRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  // Obtener todas las direcciones
  Future<List<Address>> getAddresses() async {
    try {
      final response = await _apiClient.get('addresses');

      if (response['success'] == true) {
        final List<dynamic> addressesJson = response['addresses'];
        return addressesJson.map((json) => Address.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('❌ Error obteniendo direcciones: $e');
      return [];
    }
  }

  // Obtener dirección por ID
  Future<Address?> getAddressById(String id) async {
    try {
      final response = await _apiClient.get('addresses/$id');

      if (response['success'] == true) {
        return Address.fromJson(response['address']);
      }
      return null;
    } catch (e) {
      print('❌ Error obteniendo dirección: $e');
      return null;
    }
  }

  // Crear nueva dirección
  Future<Address?> createAddress(Address address) async {
    try {
      final response = await _apiClient.post(
        'addresses',
        address.toJson(),
      );

      if (response['success'] == true) {
        return Address.fromJson(response['address']);
      }
      return null;
    } catch (e) {
      print('❌ Error creando dirección: $e');
      return null;
    }
  }

  // Actualizar dirección
  Future<Address?> updateAddress(Address address) async {
    try {
      final response = await _apiClient.put(
        'addresses/${address.id}',
        address.toJson(),
      );

      if (response['success'] == true) {
        return Address.fromJson(response['address']);
      }
      return null;
    } catch (e) {
      print('❌ Error actualizando dirección: $e');
      return null;
    }
  }

  // Eliminar dirección
  Future<bool> deleteAddress(String id) async {
    try {
      await _apiClient.delete('addresses/$id');
      return true;
    } catch (e) {
      print('❌ Error eliminando dirección: $e');
      return false;
    }
  }

  // Establecer dirección como predeterminada
  Future<Address?> setDefaultAddress(String id) async {
    try {
      final response = await _apiClient.put(
        'addresses/default/$id',
        {},
      );

      if (response['success'] == true) {
        return Address.fromJson(response['address']);
      }
      return null;
    } catch (e) {
      print('❌ Error estableciendo dirección predeterminada: $e');
      return null;
    }
  }
}
