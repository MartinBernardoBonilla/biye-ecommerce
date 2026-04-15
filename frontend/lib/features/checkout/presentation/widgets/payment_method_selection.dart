// lib/features/checkout/presentation/widgets/address_selection.dart

import 'package:biye/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:biye/features/address/domain/entities/address.dart';

import '../bloc/checkout_event.dart';

class AddressSelection extends StatelessWidget {
  final List<Address> addresses;
  final Address? selectedAddress;
  final Function(Address) onAddressSelected;

  const AddressSelection({
    super.key,
    required this.addresses,
    required this.selectedAddress,
    required this.onAddressSelected,
  });

  @override
  Widget build(BuildContext context) {
    print('📍 AddressSelection - addresses: ${addresses.length}');
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Dirección de Envío',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (addresses.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.location_off, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No tienes direcciones guardadas',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Agrega una dirección para continuar',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/addresses/add'),
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar dirección'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey[800],
                    ),
                  ),
                ],
              ),
            )
          else
            ...addresses.map((address) => _AddressTile(
                  address: address,
                  isSelected: selectedAddress?.id == address.id,
                  onTap: () => onAddressSelected(address),
                )),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextButton.icon(
              onPressed: () async {
                await Navigator.pushNamed(context, '/addresses/add');
                context.read<CheckoutBloc>().add(LoadCheckoutData());
              },
              icon: const Icon(Icons.add),
              label: const Text('Agregar nueva dirección'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  final Address address;
  final bool isSelected;
  final VoidCallback onTap;

  const _AddressTile({
    required this.address,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : null,
          border: Border(
            top: BorderSide(color: Colors.grey.withOpacity(0.2)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        address.alias,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (address.isDefault)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Predeterminada',
                            style: TextStyle(fontSize: 10, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(address.recipientName),
                  Text(address.phone),
                  Text(address.fullAddress),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
      ),
    );
  }
}
