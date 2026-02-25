import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

import 'package:biye/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:biye/features/cart/presentation/bloc/cart_event.dart';
import 'package:biye/features/cart/presentation/bloc/cart_state.dart';
import 'package:biye/features/cart/domain/entities/cart_item.dart';
import 'package:biye/features/cart/presentation/widgets/qr_bottom_sheet.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mi Carrito',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.yellow),
      ),
      body: BlocConsumer<CartBloc, CartState>(
        listener: (context, state) {
          // 🆕 Escuchamos cuando el pago es exitoso
          if (state is PaymentSuccessState) {
            // Cerrar el Bottom Sheet si está abierto
            Navigator.pop(context);

            // Mostrar mensaje de éxito
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Pago exitoso!'),
                backgroundColor: Colors.green,
              ),
            );
          }

          if (state is CheckoutErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }

          // 🆕 Escuchamos cuando el QR está listo
          if (state.qrCode != null && state.paymentMethod == 'qr') {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              isDismissible: false, // No permitir cerrar mientras se procesa
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) => QrBottomSheet(
                qrData: state.qrCode!,
                orderId: state.orderId ?? '',
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.items.isEmpty) {
            return const _EmptyCart();
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: state.items.length,
                  itemBuilder: (context, index) {
                    return _CartItemTile(item: state.items[index]);
                  },
                ),
              ),
              _CheckoutSummary(state: state),
            ],
          );
        },
      ),
    );
  }
}

/* ───────────────────────── EMPTY CART ───────────────────────── */

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Tu carrito está vacío',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

/* ───────────────────────── CHECKOUT SUMMARY ───────────────────────── */

class _CheckoutSummary extends StatelessWidget {
  final CartState state;

  const _CheckoutSummary({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black12,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTotalRow(),
          const SizedBox(height: 16),

          // Botón original: Generar Link
          if (state.initPoint == null)
            _buildActionButton(
              context: context,
              label: 'Generar link de pago',
              isLoading: state.isCheckoutLoading && state.paymentMethod != 'qr',
              onPressed: () => context.read<CartBloc>().add(StartCheckout()),
              color: Colors.yellow[700]!,
            ),

          const SizedBox(height: 12),

          // Botón: Pagar con QR
          if (state.qrCode == null)
            _buildActionButton(
              context: context,
              label: 'Pagar con QR',
              icon: Icons.qr_code_2,
              isLoading: state.isCheckoutLoading && state.paymentMethod == 'qr',
              onPressed: () =>
                  context.read<CartBloc>().add(const StartCheckoutWithQR()),
              color: Colors.blueGrey[100]!,
              textColor: Colors.black,
            ),

          // Si el link ya existe, mostramos opciones de compartir
          if (state.initPoint != null) ...[
            const Divider(),
            ElevatedButton.icon(
              icon: const Icon(Icons.share),
              label: const Text('Compartir link de pago'),
              onPressed: () =>
                  Share.share('Pagá tu pedido acá 👇\n\n${state.initPoint}'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required VoidCallback? onPressed,
    required Color color,
    IconData? icon,
    bool isLoading = false,
    Color textColor = Colors.black,
  }) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isLoading
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(strokeWidth: 2))
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: textColor),
                  const SizedBox(width: 8)
                ],
                Text(label,
                    style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ],
            ),
    );
  }

  Widget _buildTotalRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Total',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text('\$${state.total.toStringAsFixed(2)}',
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue)),
      ],
    );
  }
}

/* ───────────────────────── CART ITEM TILE ───────────────────────── */

class _CartItemTile extends StatelessWidget {
  final CartItem item;

  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CartBloc>();

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.broken_image, size: 60),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${item.price.toStringAsFixed(2)} c/u',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                _QtyButton(
                  icon: Icons.remove,
                  onTap: () => bloc.add(
                    UpdateQuantity(item.id, item.quantity - 1),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '${item.quantity}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                _QtyButton(
                  icon: Icons.add,
                  onTap: () => bloc.add(
                    UpdateQuantity(item.id, item.quantity + 1),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Text(
              '\$${(item.price * item.quantity).toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ───────────────────────── QTY BUTTON ───────────────────────── */

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}
