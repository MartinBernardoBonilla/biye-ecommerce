// custom_toast.dart - Versión definitiva corregida

import 'package:flutter/material.dart';

class CustomToast {
  static OverlayEntry? _currentOverlay;

  static void show({
    required BuildContext context,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
    Color backgroundColor = Colors.blueGrey,
    Color textColor = Colors.white,
    Color actionColor = Colors.yellow,
  }) {
    // Eliminar toast existente
    _currentOverlay?.remove();
    _currentOverlay = null;

    final overlay = Overlay.of(context);

    // ✅ Crear una referencia que se pueda usar dentro del builder
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        actionLabel: actionLabel,
        onAction: () {
          // ✅ Usar la referencia con null safety
          overlayEntry?.remove();
          _currentOverlay = null;
          // Luego ejecutar acción
          if (onAction != null) {
            Future.microtask(() => onAction());
          }
        },
        backgroundColor: backgroundColor,
        textColor: textColor,
        actionColor: actionColor,
      ),
    );

    _currentOverlay = overlayEntry;
    overlay.insert(overlayEntry);

    // Auto-cerrar
    Future.delayed(duration, () {
      if (overlayEntry!.mounted) {
        overlayEntry.remove();
        if (_currentOverlay == overlayEntry) {
          _currentOverlay = null;
        }
      }
    });
  }

  static void action({
    required BuildContext context,
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
    Duration duration = const Duration(seconds: 5),
    Color backgroundColor = Colors.blueGrey,
  }) {
    show(
      context: context,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
      backgroundColor: backgroundColor,
      actionColor: Colors.yellow,
    );
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color backgroundColor;
  final Color textColor;
  final Color actionColor;

  const _ToastWidget({
    required this.message,
    this.actionLabel,
    this.onAction,
    required this.backgroundColor,
    required this.textColor,
    required this.actionColor,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(_controller);
    _slide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 80,
      left: 20,
      right: 20,
      child: FadeTransition(
        opacity: _opacity,
        child: SlideTransition(
          position: _slide,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: widget.backgroundColor,
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
                      widget.message,
                      style: TextStyle(
                        color: widget.textColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (widget.actionLabel != null && widget.onAction != null)
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: widget.onAction,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: widget.actionColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.actionLabel!,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
