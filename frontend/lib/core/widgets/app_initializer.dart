// lib/core/widgets/app_initializer.dart

import 'package:flutter/material.dart';

class AppInitializer extends StatelessWidget {
  final Widget child;

  const AppInitializer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Sin splash de Flutter, solo mostramos la app
    // El splash HTML ya se encarga
    return child;
  }
}
