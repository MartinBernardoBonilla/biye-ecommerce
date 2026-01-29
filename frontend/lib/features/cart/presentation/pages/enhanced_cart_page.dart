import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:biye/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:biye/features/cart/presentation/bloc/cart_event.dart';
import 'package:biye/features/cart/presentation/bloc/cart_state.dart';
import 'package:biye/features/cart/domain/entities/cart_item.dart';

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
        listener: (context, state) async {
          // ✅ Checkout OK → abrir Mercado Pago
          if (state.initPoint != null) {
            final Uri uri = Uri.parse(state.initPoint!);

            if (await canLaunchUrl(uri)) {
              await launchUrl(
                uri,
                mode: LaunchMode.platformDefault,
                webOnlyWindowName: '_self',
              );
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No se pudo abrir Mercado Pago'),
                  ),
                );
              }
            }
          }

          // ❌ Error de pago
          if (state is CheckoutErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${state.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: state.isCheckoutLoading
                ? null
                : () {
                    context.read<CartBloc>().add(StartCheckout());
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow[700],
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: state.isCheckoutLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : const Text(
                    'Pagar con Mercado Pago',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
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
