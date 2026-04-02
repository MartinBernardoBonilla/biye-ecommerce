// lib/features/checkout/presentation/pages/checkout_page.dart

import 'package:biye/features/checkout/presentation/widgets/order_sumary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/checkout_bloc.dart';
import '../bloc/checkout_event.dart';
import '../bloc/checkout_state.dart';
import '../widgets/address_selection.dart';
import '../widgets/payment_method_selection.dart';

import 'checkout_success_page.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finalizar Compra'),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocListener<CheckoutBloc, CheckoutState>(
        listener: (context, state) {
          if (state is CheckoutSuccess) {
            if (state.paymentUrl != null) {
              _launchPaymentUrl(context, state.paymentUrl!);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => CheckoutSuccessPage(orderId: state.orderId),
                ),
              );
            }
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
        child: BlocBuilder<CheckoutBloc, CheckoutState>(
          builder: (context, state) {
            if (state is CheckoutLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Procesando...'),
                  ],
                ),
              );
            }

            if (state is CheckoutLoaded) {
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Selección de dirección
                          AddressSelection(
                            addresses: state.addresses,
                            selectedAddress: state.selectedAddress,
                            onAddressSelected: (address) {
                              context
                                  .read<CheckoutBloc>()
                                  .add(SelectAddress(address: address));
                            },
                          ),
                          const SizedBox(height: 24),

                          // Selección de método de pago
                          PaymentMethodSelection(
                            methods: state.paymentMethods,
                            selectedMethod: state.selectedPaymentMethod,
                            onMethodSelected: (method) {
                              context
                                  .read<CheckoutBloc>()
                                  .add(SelectPaymentMethod(method: method));
                            },
                          ),
                          const SizedBox(height: 24),

                          // Resumen del pedido
                          OrderSummary(
                            items: state.items,
                            subtotal: state.subtotal,
                            shippingCost: state.shippingCost,
                            tax: state.tax,
                            total: state.total,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Botón confirmar
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: state.canProceed
                            ? () {
                                context
                                    .read<CheckoutBloc>()
                                    .add(ConfirmOrder());
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Confirmar Pedido',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return const Center(child: Text('Cargando...'));
          },
        ),
      ),
    );
  }

  Future<void> _launchPaymentUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      // Después del pago, volver a la app
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const CheckoutSuccessPage(orderId: ''),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir el enlace de pago'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
