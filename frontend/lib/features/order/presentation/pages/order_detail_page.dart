// lib/features/order/presentation/pages/order_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:biye/features/order/presentation/bloc/order_bloc.dart';
// 📦 IMPORTAMOS EL TIMELINE QUE ESTABA HUÉRFANO:
import 'package:biye/features/order/presentation/widgets/shipping_timeline.dart';

class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({super.key});

  static const String routeName = '/order-detail';

  @override
  Widget build(BuildContext context) {
    final orderId = ModalRoute.of(context)?.settings.arguments as String?;

    if (orderId == null) {
      return const Scaffold(
        body: Center(child: Text('Orden no encontrada')),
      );
    }

    // 🎯 REEMPLAZÁ CON ESTA LÍNEA CORREGIDA (en plural y con llaves):
    context.read<OrderBloc>().add(LoadOrderDetails(orderId: orderId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Orden #${orderId.substring(0, 8)}'),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is OrderError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is OrderDetailLoaded) {
            final order = state.order;
            final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
            final currencyFormat =
                NumberFormat.currency(locale: 'es_AR', symbol: r'$');

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tarjeta de información principal
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoRow('Estado:', order.status),
                          _buildInfoRow(
                              'Fecha:', dateFormat.format(order.createdAt)),
                          _buildInfoRow(
                              'Total:', currencyFormat.format(order.total)),
                        ],
                      ),
                    ),
                  ),

                  // 🚚 SECCIÓN NUEVA: LÓGICA DE SEGUIMIENTO DE ENVÍO
                  ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Seguimiento del Envío',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        // Pasamos el objeto shipping de la orden al widget del stepper
                        child: ShippingTimeline(shipping: order.shipping!),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                  const Text(
                    'Productos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...order.items.map((item) => Card(
                        child: ListTile(
                          title: Text(item.name),
                          subtitle: Text('Cantidad: ${item.quantity}'),
                          trailing: Text(currencyFormat
                              .format(item.price * item.quantity)),
                        ),
                      )),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
