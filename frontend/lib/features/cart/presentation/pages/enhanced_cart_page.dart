import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:biye/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:biye/features/cart/presentation/bloc/cart_event.dart';
import 'package:biye/features/cart/presentation/bloc/cart_state.dart';
import 'package:biye/features/cart/domain/entities/cart_item.dart';
import 'package:biye/features/cart/presentation/widgets/qr_bottom_sheet.dart';

import 'package:biye/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:biye/features/auth/presentation/bloc/auth_state.dart';

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
          // Escuchamos cuando el pago es exitoso
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

            // Redirigir al inicio después de 2 segundos
            Future.delayed(const Duration(seconds: 2), () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            });
          }

          if (state is CheckoutErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }

          // Escuchamos cuando el QR está listo
          if (state.qrCode != null && state.paymentMethod == 'qr') {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              isDismissible: false,
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
          // Mostrar pantalla de carga mientras procesa pago
          if (state.isCheckoutLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Procesando pago...'),
                ],
              ),
            );
          }

          // Mostrar pantalla de éxito cuando el pago se completa
          if (state is PaymentSuccessState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 80),
                  const SizedBox(height: 16),
                  const Text(
                    '¡Pago exitoso!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Gracias por tu compra'),
                  const SizedBox(height: 24),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/',
                        (route) => false,
                      ),
                      child: const Text('Volver al inicio'),
                    ),
                  ),
                ],
              ),
            );
          }

          // Mostrar carrito vacío
          if (state.items.isEmpty) {
            return const _EmptyCart();
          }

          // Mostrar carrito con items
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
        children: [
          const Icon(Icons.shopping_cart_outlined,
              size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Tu carrito está vacío',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/products'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey[800],
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Ver productos'),
          ),
        ],
      ),
    );
  }
}

/* ───────────────────────── CHECKOUT SUMMARY ───────────────────────── */

class _CheckoutSummary extends StatefulWidget {
  final CartState state;
  const _CheckoutSummary({required this.state});

  @override
  State<_CheckoutSummary> createState() => __CheckoutSummaryState();
}

class __CheckoutSummaryState extends State<_CheckoutSummary> {
  final bool _isPressed = false;
  final AudioPlayer _player = AudioPlayer();

  bool get _isProcessing => widget.state.isCheckoutLoading;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _playClickSound() async {
    try {
      await _player.play(AssetSource('sounds/click.mp3'));
    } catch (e) {
      print('Error reproduciendo sonido: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🟢 Si el estado es de éxito, NO mostrar el resumen (el QR desaparece)
    if (widget.state is PaymentSuccessState) {
      return const SizedBox.shrink();
    }

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

          // Botón: Pagar con Link de pago
          if (widget.state.initPoint == null)
            _buildActionButton(
              context: context,
              label: 'Pagar con link',
              icon: Icons.link,
              isLoading: _isProcessing && widget.state.paymentMethod != 'qr',
              onPressed: () => context.read<CartBloc>().add(StartCheckout()),
              color: Colors.yellow[700]!,
            ),

          const SizedBox(height: 12),

          // Botón: Pagar con QR con efectos
          if (widget.state.qrCode == null)
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                print('🔄 [CART] AuthState cambiado: ${authState.runtimeType}');

                // Determinar si está autenticado (cualquier forma)
                final isAuthenticated = authState is AuthAuthenticated ||
                    authState is AuthTokenAuthenticated;

                // Obtener el rol de forma segura
                String? role;
                if (authState is AuthAuthenticated) {
                  role = authState.userData?['role'];
                } else if (authState is AuthTokenAuthenticated) {
                  role = authState.userData['role'];
                }

                final isAdmin = isAuthenticated && role == 'admin';

                // Si es admin, mostrar mensaje de que no puede comprar
                if (isAdmin) {
                  return MouseRegion(
                    cursor: SystemMouseCursors.forbidden,
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Los administradores no pueden realizar compras'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      },
                      child: _buildActionButton(
                        context: context,
                        label: 'Modo administrador',
                        icon: Icons.admin_panel_settings,
                        isLoading: false,
                        onPressed: null,
                        color: Colors.grey[300]!,
                        textColor: Colors.grey[600]!,
                      ),
                    ),
                  );
                }

                // Usuario normal autenticado
                if (isAuthenticated) {
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          print('👆 Botón QR TOCADO');
                          _playClickSound();
                          context
                              .read<CartBloc>()
                              .add(const StartCheckoutWithQR());
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.yellow[700]!,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Pagar con QR (TEST)',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                // Usuario no autenticado
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (_) => print('🟡 Mouse ENTER en botón gris'),
                  onExit: (_) => print('🟡 Mouse EXIT en botón gris'),
                  child: GestureDetector(
                    onTap: () {
                      print('👆 Tap en botón gris');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Debes iniciar sesión para pagar con QR'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      Navigator.pushNamed(context, '/login');
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[300]!,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.login, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              'Iniciar sesión para pagar',
                              style: TextStyle(color: Colors.grey[600]!),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

          // Si el link ya existe, mostramos opciones de compartir
          if (widget.state.initPoint != null && !_isProcessing) ...[
            const Divider(),
            ElevatedButton.icon(
              icon: const Icon(Icons.share),
              label: const Text('Compartir link de pago'),
              onPressed: () {
                Share.share(
                    'Pagá tu pedido acá 👇\n\n${widget.state.initPoint}');
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.copy),
              label: const Text('Copiar link'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: widget.state.initPoint!));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Link copiado al portapapeles'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
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
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
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
        Text('\$${widget.state.total.toStringAsFixed(2)}',
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

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Card(
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
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16),
        ),
      ),
    );
  }
}
