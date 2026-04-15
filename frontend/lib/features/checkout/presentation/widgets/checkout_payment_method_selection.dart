import 'package:flutter/material.dart';
import 'package:biye/features/payment_methods/domain/entities/payment_method.dart';

class CheckoutPaymentMethodSelection extends StatelessWidget {
  final List<PaymentMethod> methods;
  final PaymentMethod? selectedMethod;
  final String? selectedMethodId;
  final Function(PaymentMethod) onMethodSelected;

  const CheckoutPaymentMethodSelection({
    super.key,
    required this.methods,
    this.selectedMethod,
    this.selectedMethodId,
    required this.onMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Método QR manual
    final qrMethod = PaymentMethod(
      id: 'qr_manual',
      type: 'qr',
      name: 'Mercado Pago QR',
      displayName: 'Pagar con QR',
      isDefault: false,
    );

    // ✅ Determinar si QR está seleccionado
    final isQRSelected = selectedMethodId == 'qr_manual';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Método de Pago',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // ✅ QR manual
        GestureDetector(
          onTap: () => onMethodSelected(qrMethod),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isQRSelected ? Colors.yellow : Colors.grey.withOpacity(0.3),
                width: isQRSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.qr_code,
                    color: isQRSelected ? Colors.yellow : Colors.grey,
                    size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pagar con QR',
                        style: TextStyle(
                          fontWeight: isQRSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isQRSelected ? Colors.yellow : Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Escanea el código QR desde la app de Mercado Pago',
                        style: TextStyle(color: Colors.green, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (isQRSelected)
                  const Icon(Icons.check_circle,
                      color: Colors.yellow, size: 24),
              ],
            ),
          ),
        ),

        // ✅ Tarjetas guardadas
        ...methods.map((method) {
          final isSelected = selectedMethodId == method.id;
          return GestureDetector(
            onTap: () => onMethodSelected(method),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isSelected ? Colors.yellow : Colors.grey.withOpacity(0.3),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.credit_card,
                      color: isSelected ? Colors.yellow : Colors.grey,
                      size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          method.displayName,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected ? Colors.yellow : Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        if (method.cardDetails != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '**** ${method.cardDetails!.lastFourDigits}',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle,
                        color: Colors.yellow, size: 24),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
