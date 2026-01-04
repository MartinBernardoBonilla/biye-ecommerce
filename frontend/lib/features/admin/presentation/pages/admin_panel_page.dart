import 'package:flutter/material.dart';

class AdminPanelPage extends StatelessWidget {
  const AdminPanelPage({super.key});

  static const String routeName = '/admin/panel';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            // ⭐️ AGREGAR ESTO
            child: Padding(
              padding: EdgeInsets.all(
                constraints.maxWidth < 600 ? 12.0 : 16.0, // Responsive padding
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // ⭐️ IMPORTANTE
                children: [
                  // Encabezado
                  Text(
                    'Dashboard Administrativo',
                    style: TextStyle(
                      fontSize: constraints.maxWidth < 600 ? 20 : 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gestión completa de la plataforma Biye',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: constraints.maxWidth < 600 ? 12 : 14,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Estadísticas rápidas - GRID RESPONSIVE
                  GridView.count(
                    shrinkWrap: true, // ⭐️ IMPORTANTE
                    physics:
                        const NeverScrollableScrollPhysics(), // ⭐️ IMPORTANTE
                    crossAxisCount: constraints.maxWidth < 600
                        ? 2
                        : 4, // Responsive columns
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: constraints.maxWidth < 600 ? 1.3 : 1.5,
                    children: [
                      _buildStatCard(
                        context,
                        'Productos',
                        '0',
                        Icons.shopping_bag,
                        Colors.blue,
                        () {
                          Navigator.pushNamed(
                              context, '/admin-product-management');
                        },
                      ),
                      _buildStatCard(
                        context,
                        'Stock Bajo',
                        '0',
                        Icons.warning,
                        Colors.orange,
                        null,
                      ),
                      _buildStatCard(
                        context,
                        'Sin Stock',
                        '0',
                        Icons.block,
                        Colors.red,
                        null,
                      ),
                      _buildStatCard(
                        context,
                        'Productos Activos',
                        '0',
                        Icons.check_circle,
                        Colors.green,
                        null,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Acciones rápidas
                  Text(
                    'Acciones Rápidas',
                    style: TextStyle(
                      fontSize: constraints.maxWidth < 600 ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Grid de acciones - RESPONSIVE
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: constraints.maxWidth < 600 ? 2 : 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: constraints.maxWidth < 600 ? 3.0 : 2.5,
                    children: [
                      _buildActionCard(
                        'Gestionar Productos',
                        Icons.inventory_2,
                        Colors.teal,
                        () {
                          Navigator.pushNamed(
                              context, '/admin-product-management');
                        },
                      ),
                      _buildActionCard(
                        'Crear Producto',
                        Icons.add_circle,
                        Colors.green,
                        () {
                          Navigator.pushNamed(context, '/admin/create-product');
                        },
                      ),
                      _buildActionCard(
                        'Ver Pedidos',
                        Icons.receipt_long,
                        Colors.purple,
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Funcionalidad en desarrollo'),
                            ),
                          );
                        },
                      ),
                      _buildActionCard(
                        'Ver Usuarios',
                        Icons.people,
                        Colors.blue,
                        () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Funcionalidad en desarrollo'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  // Espacio extra al final
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12), // REDUCIR padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // ⭐️ IMPORTANTE
            children: [
              Icon(icon, size: 28, color: color), // REDUCIR tamaño
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18, // REDUCIR tamaño
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10, // REDUCIR tamaño
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(10), // REDUCIR padding
          child: Row(
            children: [
              Icon(icon, color: color, size: 20), // REDUCIR tamaño
              const SizedBox(width: 10),
              Flexible(
                // ⭐️ AGREGAR Flexible
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12, // REDUCIR tamaño
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
