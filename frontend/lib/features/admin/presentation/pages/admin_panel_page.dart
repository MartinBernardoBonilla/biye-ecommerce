import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:biye/features/admin/presentation/bloc/admin_bloc.dart'; // 👈 ÚNICO IMPORT
import 'package:biye/features/admin/presentation/utils/order_ui_helper.dart';

class AdminPanelPage extends StatelessWidget {
  const AdminPanelPage({super.key});

  static const String routeName = '/admin/panel';

  @override
  Widget build(BuildContext context) {
    // 🔍 LOGS DE DEPURACIÓN CRUCIALES
    debugPrint('=' * 50);
    debugPrint('🚧🚧🚧 CONSTRUYENDO ADMIN PANEL PAGE 🚧🚧🚧');
    debugPrint('📍 Route: ${ModalRoute.of(context)?.settings.name}');
    debugPrint('📍 AdminBloc exists: ${context.read<AdminBloc>() != null}');

    // Disparar evento para cargar estadísticas al entrar
    context.read<AdminBloc>().add(LoadAdminDashboard());
    debugPrint('📊 Evento LoadAdminDashboard disparado');
    debugPrint('=' * 50);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        backgroundColor: Colors.blueGrey[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              debugPrint('🔄 Refrescando dashboard...');
              context.read<AdminBloc>().add(LoadAdminDashboard());
            },
          ),
        ],
      ),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          debugPrint('📊 BlocBuilder - Estado: ${state.runtimeType}');

          if (state is AdminLoading) {
            debugPrint('⏳ Mostrando indicador de carga...');
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AdminError) {
            debugPrint('❌ Error en admin: ${state.message}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      debugPrint('🔄 Reintentando carga...');
                      context.read<AdminBloc>().add(LoadAdminDashboard());
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          // State loaded con datos reales
          final stats = state is AdminLoaded ? state.stats : null;
          debugPrint(
              '✅ AdminLoaded - Stats: ${stats != null ? 'disponibles' : 'null'}');

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(
                    constraints.maxWidth < 600 ? 12.0 : 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
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

                      // 📊 ESTADÍSTICAS
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: constraints.maxWidth < 600 ? 2 : 4,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio:
                            constraints.maxWidth < 600 ? 1.3 : 1.5,
                        children: [
                          _buildStatCard(
                            context,
                            'Productos',
                            stats?.totalProducts?.toString() ?? '0',
                            Icons.shopping_bag,
                            Colors.blue,
                            () {
                              debugPrint('📦 Navegando a gestión de productos');
                              Navigator.pushNamed(
                                  context, '/admin-product-management');
                            },
                          ),
                          _buildStatCard(
                            context,
                            'Stock Bajo',
                            stats?.lowStockCount?.toString() ?? '0',
                            Icons.warning,
                            Colors.orange,
                            () {
                              debugPrint(
                                  '⚠️ Navegando a productos con stock bajo');
                              Navigator.pushNamed(
                                context,
                                '/admin-product-management',
                                arguments: {'filter': 'lowStock'},
                              );
                            },
                          ),
                          _buildStatCard(
                            context,
                            'Sin Stock',
                            stats?.outOfStockCount?.toString() ?? '0',
                            Icons.block,
                            Colors.red,
                            () {
                              debugPrint('🚫 Navegando a productos sin stock');
                              Navigator.pushNamed(
                                context,
                                '/admin-product-management',
                                arguments: {'filter': 'outOfStock'},
                              );
                            },
                          ),
                          _buildStatCard(
                            context,
                            'Productos Activos',
                            stats?.activeProducts?.toString() ?? '0',
                            Icons.check_circle,
                            Colors.green,
                            () {
                              debugPrint('✅ Navegando a productos activos');
                              Navigator.pushNamed(
                                context,
                                '/admin-product-management',
                                arguments: {'filter': 'active'},
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // ⚡ ACCIONES RÁPIDAS
                      Text(
                        'Acciones Rápidas',
                        style: TextStyle(
                          fontSize: constraints.maxWidth < 600 ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: constraints.maxWidth < 600 ? 2 : 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio:
                            constraints.maxWidth < 600 ? 3.0 : 2.5,
                        children: [
                          _buildActionCard(
                            'Gestionar Productos',
                            Icons.inventory_2,
                            Colors.teal,
                            () {
                              debugPrint('📦 Navegando a gestión de productos');
                              Navigator.pushNamed(
                                  context, '/admin-product-management');
                            },
                          ),
                          _buildActionCard(
                            'Crear Producto',
                            Icons.add_circle,
                            Colors.green,
                            () {
                              debugPrint('➕ Navegando a creación de producto');
                              Navigator.pushNamed(
                                  context, '/admin/create-product');
                            },
                          ),
                          _buildActionCard(
                            'Ver Pedidos',
                            Icons.receipt_long,
                            Colors.purple,
                            () {
                              debugPrint('📋 Navegando a pedidos');
                              Navigator.pushNamed(context, '/admin/orders');
                            },
                          ),
                          _buildActionCard(
                            'Ver Usuarios',
                            Icons.people,
                            Colors.blue,
                            () {
                              debugPrint('👥 Navegando a usuarios');
                              Navigator.pushNamed(context, '/admin/users');
                            },
                          ),
                        ],
                      ),

                      // 📦 ÚLTIMOS PEDIDOS
                      if (stats?.recentOrders != null &&
                          stats!.recentOrders!.isNotEmpty) ...[
                        const SizedBox(height: 32),
                        Text(
                          'Últimos Pedidos',
                          style: TextStyle(
                            fontSize: constraints.maxWidth < 600 ? 16 : 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...stats.recentOrders!.map((order) {
                          debugPrint('📦 Mostrando orden: ${order.id}');
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    OrderUiHelper.getStatusColor(order.status),
                                child: Text(
                                  '\$${order.totalAmount?.toStringAsFixed(0) ?? '0'}',
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.white),
                                ),
                              ),
                              title: Text(
                                  'Orden #${order.id?.substring(0, 8) ?? 'N/A'}'),
                              subtitle: Text(
                                '${order.items?.length ?? 0} productos - ${OrderUiHelper.getStatusText(order.status)}',
                              ),
                              trailing: Text(
                                OrderUiHelper.formatDate(order.createdAt),
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                              onTap: () {
                                debugPrint(
                                    '🔍 Navegando a detalle de orden: ${order.id}');
                                Navigator.pushNamed(
                                  context,
                                  '/admin/order-detail',
                                  arguments: order.id,
                                );
                              },
                            ),
                          );
                        }).toList(),
                      ],

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // 🎨 Tarjeta de estadística
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
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🎨 Tarjeta de acción
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
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
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
