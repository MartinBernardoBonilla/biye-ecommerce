import 'package:flutter/material.dart';

class AdminEditProductPage extends StatelessWidget {
  const AdminEditProductPage({super.key});

  static const String routeName = '/admin/edit-product';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Producto')),
      body: const Center(child: Text('Editar producto existente')),
    );
  }
}
