import 'package:flutter/material.dart';

class PaymentPendingPage extends StatelessWidget {
  const PaymentPendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hourglass_top, size: 80, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'Pago pendiente',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Te avisaremos cuando se confirme'),
          ],
        ),
      ),
    );
  }
}
