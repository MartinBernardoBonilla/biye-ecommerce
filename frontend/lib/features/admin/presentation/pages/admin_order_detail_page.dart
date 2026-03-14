// lib/features/admin/presentation/pages/admin_order_detail_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:biye/features/admin/domain/entities/admin_order.dart';
import 'package:biye/features/admin/presentation/utils/order_ui_helper.dart';

class AdminOrderDetailPage extends StatelessWidget {
  const AdminOrderDetailPage({super.key});

  static const String routeName = '/admin/order-detail';

  @override
  Widget build(BuildContext context) {
    final order = ModalRoute.of(context)?.settings.arguments as AdminOrder?;

    if (order == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Colors.red,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('Orden no encontrada'),
            ],
          ),
        ),
      );
    }

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final currencyFormat = NumberFormat.currency(locale: 'es_AR', symbol: r'$');

    return Scaffold(
      appBar: AppBar(
        title: Text('Orden #${order.id.substring(0, 8)}'),
        backgroundColor: Colors.blueGrey[800],
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
                  OrderUiHelper.getStatusColor(order.status).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: OrderUiHelper.getStatusColor(order.status),
              ),
            ),
            child: Text(
              OrderUiHelper.getStatusText(order.status),
              style: TextStyle(
                color: OrderUiHelper.getStatusColor(order.status),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📦 INFORMACIÓN DEL PEDIDO
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información del Pedido',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    _buildInfoRow('ID Completo:', order.id),
                    _buildInfoRow('Fecha:', dateFormat.format(order.createdAt)),
                    _buildInfoRow(
                        'Total:', currencyFormat.format(order.totalAmount)),
                    if (order.paidAt != null)
                      _buildInfoRow(
                          'Pagado:', dateFormat.format(order.paidAt!)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 👤 INFORMACIÓN DEL CLIENTE
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cliente',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    _buildInfoRow('Nombre:', order.customerName ?? 'Invitado'),
                    _buildInfoRow(
                        'Email:', order.customerEmail ?? 'No especificado'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 💳 INFORMACIÓN DE PAGO
            if (order.paymentDetails != null) ...[
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detalles del Pago',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      if (order.paymentDetails!['method'] != null)
                        _buildInfoRow(
                            'Método:',
                            order.paymentDetails!['method']
                                .toString()
                                .toUpperCase()),
                      if (order.paymentDetails!['paymentId'] != null)
                        _buildInfoRow('ID Pago:',
                            order.paymentDetails!['paymentId'].toString()),
                      if (order.paymentDetails!['preferenceId'] != null)
                        _buildInfoRow('Preferencia:',
                            order.paymentDetails!['preferenceId'].toString()),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 🛒 PRODUCTOS
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Productos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${order.items.length} artículos',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: order.items.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final item = order.items[index];
                        return Row(
                          children: [
                            // Imagen del producto (si existe)
                            if (item.productImage != null)
                              Container(
                                width: 50,
                                height: 50,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(item.productImage!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: 50,
                                height: 50,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.image_not_supported,
                                    color: Colors.grey),
                              ),

                            // Detalles del producto
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item.quantity} x ${currencyFormat.format(item.unitPrice)}',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Subtotal
                            Text(
                              currencyFormat.format(item.totalPrice),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const Divider(),
                    // Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          currencyFormat.format(order.totalAmount),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 🎯 ACCIONES (opcional)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Volver a la lista
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Volver'),
                  ),
                ),
                const SizedBox(width: 8),
                if (order.status != 'PAID')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Aquí podrías agregar lógica para actualizar estado
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Funcionalidad en desarrollo'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.update),
                      label: const Text('Actualizar Estado'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
