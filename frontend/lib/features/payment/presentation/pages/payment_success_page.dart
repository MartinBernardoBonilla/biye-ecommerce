import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class PaymentSuccessPage extends StatefulWidget {
  final String? orderId;

  const PaymentSuccessPage({super.key, this.orderId});

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();

    // 🎬 Animación
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _controller.forward();

    // 🔊 Sonido
    _playSuccessSound();
  }

  Future<void> _playSuccessSound() async {
    try {
      await _player.play(AssetSource('sounds/payment_success.mp3'));
    } catch (_) {}
  }

  @override
  void dispose() {
    _controller.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // dark pro
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ✅ CHECK ANIMADO
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.6),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // 🎉 TEXTO PRINCIPAL
              const Text(
                'Pago exitoso',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Tu compra fue procesada correctamente',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 24),

              // 🧾 ORDER ID
              if (widget.orderId != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Orden: ${widget.orderId}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),

              const SizedBox(height: 40),

              // 🔘 BOTÓN PRINCIPAL
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/',
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Volver al inicio',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 🔍 SECUNDARIO
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/orders');
                },
                child: const Text(
                  'Ver mis pedidos',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
