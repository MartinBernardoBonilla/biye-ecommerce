import 'package:flutter/material.dart';

class OverlayHelper {
  static void showAddedToCart({
    required BuildContext context,
    required String productName,
    required VoidCallback onViewCart,
  }) {
    final overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _AddedToCartOverlay(
        productName: productName,
        onViewCart: onViewCart,
        overlayEntry: overlayEntry,
      ),
    );

    overlayState.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 10), () {
      if (overlayEntry.mounted) overlayEntry.remove();
    });
  }
}

class _AddedToCartOverlay extends StatefulWidget {
  final String productName;
  final VoidCallback onViewCart;
  final OverlayEntry overlayEntry;

  const _AddedToCartOverlay({
    required this.productName,
    required this.onViewCart,
    required this.overlayEntry,
  });

  @override
  State<_AddedToCartOverlay> createState() => __AddedToCartOverlayState();
}

class __AddedToCartOverlayState extends State<_AddedToCartOverlay> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
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
                  '${widget.productName} agregado',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  widget.overlayEntry.remove();
                  widget.onViewCart();
                },
                onHover: (hovering) {
                  setState(() => _isHovered = hovering);
                },
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: _isHovered ? Colors.green[50]! : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: _isHovered
                        ? Border.all(color: Colors.green, width: 2)
                        : null,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'VER',
                    style: TextStyle(
                      color: _isHovered ? Colors.green[800]! : Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      decoration: _isHovered ? TextDecoration.underline : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
