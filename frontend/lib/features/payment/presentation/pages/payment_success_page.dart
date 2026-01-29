import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:biye/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:biye/features/cart/presentation/bloc/cart_event.dart';

class PaymentSuccessPage extends StatefulWidget {
  const PaymentSuccessPage({super.key});

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  bool _cartCleared = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 🧹 Limpiamos carrito SOLO una vez
    if (!_cartCleared) {
      context.read<CartBloc>().add(ClearCart());
      _cartCleared = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pago exitoso'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            const Text(
              '¡Pago realizado con éxito!',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/', (_) => false);
              },
              child: const Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    );
  }
}
