// lib/features/checkout/presentation/widgets/payment_method_selection.dart

import 'package:flutter/material.dart';
import 'package:biye/features/payment_methods/domain/entities/payment_method.dart';

class PaymentMethodSelection extends StatelessWidget {
  final List<PaymentMethod> methods;
  final PaymentMethod? selectedMethod;
  final Function(PaymentMethod) onMethodSelected;

  const PaymentMethodSelection({
    super.key,
    required this.methods,
    required this.selectedMethod,
    required this.onMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
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
              'Método de Pago',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (methods.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No tienes métodos de pago guardados'),
            )
          else
            ...methods.map((method) => _PaymentMethodTile(
                  method: method,
                  isSelected: selectedMethod?.id == method.id,
                  onTap: () => onMethodSelected(method),
                )),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/payment-methods/add').then((_) {
                  // Recargar datos
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Agregar nuevo método de pago'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.method,
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
                      Icon(
                        Icons.credit_card,
                        size: 24,
                        color: _getBrandColor(method.cardDetails?.brand),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        method.displayName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (method.isDefault)
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
                            'Predeterminado',
                            style: TextStyle(fontSize: 10, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                  if (method.cardDetails != null) ...[
                    const SizedBox(height: 4),
                    Text(
                        'Vence: ${method.cardDetails!.expirationMonth}/${method.cardDetails!.expirationYear}'),
                    Text(method.cardDetails!.cardholderName),
                  ],
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
      ),
    );
  }

  Color _getBrandColor(String? brand) {
    if (brand == null) return Colors.grey;
    switch (brand.toLowerCase()) {
      case 'visa':
        return Colors.blue;
      case 'mastercard':
        return Colors.red;
      case 'amex':
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }
}
