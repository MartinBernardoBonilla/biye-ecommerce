import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:biye/features/address/presentation/bloc/address_bloc.dart';
import 'package:biye/features/address/presentation/bloc/address_state.dart';
import 'package:biye/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:biye/features/cart/presentation/bloc/cart_event.dart';
import 'package:biye/features/payment_methods/presentation/bloc/payment_method_bloc.dart';
import 'package:biye/features/payment_methods/presentation/bloc/payment_method_state.dart';

import '../bloc/checkout_bloc.dart';
import '../bloc/checkout_event.dart' as checkout;
import '../bloc/checkout_state.dart';
import '../widgets/checkout_address_selection.dart';
import '../widgets/checkout_payment_method_selection.dart';
import '../widgets/order_sumary.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String? _lastOrderId;

  @override
  void initState() {
    super.initState();
    context.read<CheckoutBloc>().add(checkout.InitializeCheckout());
    context.read<CheckoutBloc>().add(checkout.LoadCheckoutData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finalizar Compra'),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
      ),
      body: BlocListener<CheckoutBloc, CheckoutState>(
        listener: (context, state) {
          if (state is CheckoutOrderCreated) {
            _lastOrderId = state.orderId;
            if (state.qrData != null) {
              if (state.paymentMethodType == 'qr' ||
                  state.paymentMethodType == 'qr_manual') {
                _showQRDialog(
                    context, state.qrData!, state.qrImageBase64, state.orderId);
              } else {
                _openPaymentUrl(context, state.qrData!, state.orderId);
              }
            }
          }

          if (state is CheckoutPaymentConfirmed) {
            if (Navigator.canPop(context)) Navigator.pop(context);
            _showSuccessAndNavigate(context);
          }

          if (state is CheckoutError) {
            if (state.message.contains('Tiempo de espera') &&
                _lastOrderId != null) {
              if (Navigator.canPop(context)) Navigator.pop(context);
              _showTimeoutDialog(context, _lastOrderId!);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          }
        },
        child: BlocBuilder<CheckoutBloc, CheckoutState>(
          builder: (context, state) {
            final addressState = context.watch<AddressBloc>().state;
            final paymentState = context.watch<PaymentMethodBloc>().state;

            if (addressState is! AddressesLoaded ||
                paymentState is! PaymentMethodsLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CheckoutLoaded) {
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          CheckoutAddressSelection(
                            addresses: state.addresses,
                            selectedAddress: state.selectedAddress,
                            onAddressSelected: (a) => context
                                .read<CheckoutBloc>()
                                .add(checkout.SelectAddress(address: a)),
                          ),
                          const SizedBox(height: 24),
                          CheckoutPaymentMethodSelection(
                            methods: state.paymentMethods,
                            selectedMethod: state.selectedPaymentMethod,
                            selectedMethodId: state.selectedPaymentMethodId,
                            onMethodSelected: (m) => context
                                .read<CheckoutBloc>()
                                .add(checkout.SelectPaymentMethod(method: m)),
                          ),
                          const SizedBox(height: 24),
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
                  _buildBottomButton(context, state),
                ],
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildBottomButton(BuildContext context, CheckoutLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: state.canProceed
              ? () => context.read<CheckoutBloc>().add(checkout.ConfirmOrder())
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Confirmar Pedido',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
        ),
      ),
    );
  }

  // --- FUNCIONES DE DIÁLOGOS Y NAVEGACIÓN ---

  Future<void> _openPaymentUrl(
      BuildContext context, String url, String orderId) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      // Iniciamos el polling después de abrir el navegador
      context
          .read<CheckoutBloc>()
          .add(checkout.CheckPaymentStatus(orderId: orderId));
      _showWaitingDialog(context, orderId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace de pago')),
      );
    }
  }

  void _showQRDialog(BuildContext context, String qrData, String? qrImageBase64,
      String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Pagar con QR'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Escaneá este código con la app de Mercado Pago',
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: qrImageBase64 != null && qrImageBase64.isNotEmpty
                  ? Image.memory(base64Decode(qrImageBase64),
                      width: 200, height: 200)
                  : QrImageView(
                      data: qrData, size: 200, backgroundColor: Colors.white),
            ),
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
            const SizedBox(height: 8),
            const Text('Esperando confirmación...',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CheckoutBloc>().add(checkout.StopPolling());
            },
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _showWaitingDialog(BuildContext context, String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Esperando confirmación'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Procesando tu pago...'),
            SizedBox(height: 8),
            Text('No cierres esta ventana', style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CheckoutBloc>().add(checkout.StopPolling());
            },
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _showTimeoutDialog(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Aún no pagaste?'),
        content: const Text(
            'No pudimos confirmar el pago automáticamente. Si ya pagaste, podemos verificar el estado ahora.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Esperar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context
                  .read<CheckoutBloc>()
                  .add(checkout.CheckPaymentStatus(orderId: orderId));
            },
            child: const Text('Verificar Pago'),
          ),
        ],
      ),
    );
  }

  void _showSuccessAndNavigate(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 8),
            Text('¡Pago Exitoso!'),
          ],
        ),
        content: const Text('Tu pago ha sido procesado correctamente.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CartBloc>().add(ClearCart());
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            child: const Text('Volver al Inicio'),
          ),
        ],
      ),
    );
  }
}
