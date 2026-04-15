import 'package:biye/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:biye/features/checkout/presentation/bloc/checkout_event.dart';
import 'package:biye/features/checkout/presentation/bloc/checkout_state.dart';
import 'package:biye/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:biye/features/cart/presentation/bloc/cart_event.dart';
import 'package:biye/features/payment/presentation/pages/payment_success_page.dart'; // ✅ Importar el existente
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentPage extends StatefulWidget {
  final String orderId;
  final String? qrData;
  final String? paymentLink;

  const PaymentPage({
    super.key,
    required this.orderId,
    this.qrData,
    this.paymentLink,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  @override
  void initState() {
    super.initState();
    context.read<CheckoutBloc>().add(
          CheckPaymentStatus(orderId: widget.orderId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagar Pedido'),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
      ),
      body: BlocListener<CheckoutBloc, CheckoutState>(
        listener: (context, state) {
          if (state is CheckoutPaymentConfirmed) {
            // Limpiar carrito
            context.read<CartBloc>().add(ClearCart());

            // ✅ Usar la pantalla de éxito existente
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => const PaymentSuccessPage(),
              ),
              (route) => false,
            );
          }

          if (state is CheckoutError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Escaneá para pagar',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Usá MercadoPago desde tu celular',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                if (widget.qrData != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: QrImageView(
                      data: widget.qrData!,
                      size: 250,
                      backgroundColor: Colors.white,
                    ),
                  ),
                const SizedBox(height: 24),
                if (widget.paymentLink != null) ...[
                  const Text(
                    'O pagá desde este link:',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final url = Uri.parse(widget.paymentLink!);
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url,
                                  mode: LaunchMode.externalApplication);
                            }
                          },
                          icon: const Icon(Icons.open_in_browser),
                          label: const Text('Abrir link'),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: widget.paymentLink!),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Link copiado')),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.share),
                        onPressed: () {
                          Share.share(widget.paymentLink!);
                        },
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 48),
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text(
                  'Esperando confirmación del pago...',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  'No cierres esta pantalla',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
