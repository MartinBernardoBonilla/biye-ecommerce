import 'package:flutter/material.dart';

class PaymentFailurePage extends StatelessWidget {
  const PaymentFailurePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cancel, size: 80, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Pago rechazado',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Intentá nuevamente'),
          ],
        ),
      ),
    );
  }
}
