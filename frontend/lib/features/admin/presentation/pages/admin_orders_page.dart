// lib/features/admin/presentation/pages/admin_orders_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:biye/features/admin/presentation/bloc/admin_bloc.dart'; // 👈 ÚNICO IMPORT
import 'package:biye/features/admin/presentation/utils/order_ui_helper.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  static const String routeName = '/admin/orders';

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage> {
  final ScrollController _scrollController = ScrollController();
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _scrollController.addListener(_onScroll);
  }

  void _loadOrders() {
    context.read<AdminBloc>().add(LoadOrders(page: _page));
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<AdminBloc>().state;
      if (state is AdminLoaded && state.hasMoreOrders) {
        _page++;
        _loadOrders();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Pedidos'),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading && _page == 1) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AdminError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  ElevatedButton(
                    onPressed: () {
                      _page = 1;
                      _loadOrders();
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is AdminLoaded) {
            final orders = state.orders;
            debugPrint(
                '📱 [ORDERS PAGE] Total órdenes en estado: ${orders.length}');
            if (orders.isEmpty) {
              return const Center(child: Text('No hay pedidos'));
            }

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: orders.length + (state.hasMoreOrders ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == orders.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final order = orders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          OrderUiHelper.getStatusColor(order.status),
                      child: Text(
                        '\$${order.totalAmount.toStringAsFixed(0) ?? '0'}',
                        style:
                            const TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                    title: Text('Orden #${order.id.substring(0, 8) ?? 'N/A'}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${order.items.length ?? 0} productos'),
                        Text('Cliente: ${order.customerName ?? 'Invitado'}'),
                        Text(
                            'Estado: ${OrderUiHelper.getStatusText(order.status)}'),
                      ],
                    ),
                    trailing: Text(
                      OrderUiHelper.formatDate(order.createdAt),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/admin/order-detail',
                        arguments: order,
                      );
                    },
                  ),
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
