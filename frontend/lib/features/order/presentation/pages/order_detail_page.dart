// lib/features/order/presentation/pages/order_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:biye/features/order/presentation/bloc/order_bloc.dart';

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
                  const SizedBox(height: 16),
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
