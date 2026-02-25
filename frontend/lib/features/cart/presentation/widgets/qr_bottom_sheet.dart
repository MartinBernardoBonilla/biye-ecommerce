import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrBottomSheet extends StatelessWidget {
  final String qrData;
  final String orderId;

  const QrBottomSheet({
    super.key,
    required this.qrData,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Escaneá para pagar',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          // Aquí usamos la librería qr_flutter
          QrImageView(
            data: qrData,
            version: QrVersions.auto,
            size: 250.0,
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: 20),
          const Text(
            'Abrí Mercado Pago y escaneá este código para completar tu pedido BIYE',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          Text('Orden: $orderId'),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
