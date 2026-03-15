import 'package:flutter/material.dart';

class OverlayHelper {
  static void showAddedToCart({
    required BuildContext context,
    required String productName,
    required VoidCallback onViewCart,
  }) {
    print('🎯 Intentando mostrar overlay para $productName');

    final overlayState = Overlay.of(context);

    if (overlayState == null) {
      print('❌ No se pudo encontrar Overlay');
      return;
    }

    print('✅ Overlay encontrado, creando entry...');

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
        print('🔄 Construyendo overlay para $productName');
        return Positioned(
          bottom: 80,
          left: 20,
          right: 20,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '$productName agregado',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        print('👆 Botón VER presionado');
                        overlayEntry.remove();
                        onViewCart();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'VER',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    print('📦 Insertando overlay...');
    overlayState.insert(overlayEntry);
    print('✅ Overlay insertado');

    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        print('⏰ Auto-removiendo overlay');
        overlayEntry.remove();
      }
    });
  }
}
