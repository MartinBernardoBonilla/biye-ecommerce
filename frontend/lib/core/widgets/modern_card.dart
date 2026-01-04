// lib/shared/widgets/modern_card.dart
import 'package:flutter/material.dart';

class ModernCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double? elevation;

  const ModernCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.elevation = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      // Aplica la elevación (sombra)
      elevation: elevation,
      // Define la forma con esquinas redondeadas
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        // Si onTap es null, el InkWell no es pulsable
        onTap: onTap,
        // Asegura que el efecto ripple respete las esquinas
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          // Si no se especifica padding, usa 16 en todos los lados
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}
