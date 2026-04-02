// lib/features/order/presentation/pages/my_orders_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:biye/features/order/presentation/bloc/order_bloc.dart';

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

  static const String routeName = '/my-orders';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Pedidos'),
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
          if (state is OrderLoaded) {
            if (state.orders.isEmpty) {
              return const Center(child: Text('No tienes pedidos aún'));
            }
            return ListView.builder(
              itemCount: state.orders.length,
              itemBuilder: (ctx, i) {
                final order = state.orders[i];
                return ListTile(
                  title: Text('Orden #${order.id?.substring(0, 8) ?? 'N/A'}'),
                  subtitle: Text(
                      'Total: \$${order.total.toStringAsFixed(2)} - ${order.status}'),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/order-detail',
                      arguments: order.id,
                    );
                  },
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
