import 'package:biye/features/admin/presentation/pages/admin_panel_page.dart';
import 'package:biye/features/auth/presentation/login_screen.dart';
import 'package:biye/features/auth/presentation/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:biye/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:biye/features/auth/presentation/bloc/auth_state.dart';
import 'package:biye/features/auth/presentation/bloc/auth_event.dart';
import 'package:biye/features/order/presentation/pages/my_orders_page.dart';
import 'package:biye/features/admin/presentation/pages/admin_login_page.dart';
import 'package:biye/core/utils/route_transitions.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const String routeName = '/profile';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: Colors.blueGrey[800],
        elevation: 0,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          // Si no está autenticado, mostrar opciones de login
          if (state is! AuthAuthenticated) {
            return _buildNotAuthenticated(context);
          }

          // Usuario autenticado
          final user = state.user;
          final userData = state.userData ?? {};
          final String email = user.email ?? userData['email'] ?? 'Sin email';
          final String displayName =
              user.displayName ?? userData['name'] ?? email.split('@').first;
          final String role = userData['role'] ?? 'user';
          final bool isAdmin = role == 'admin';

          return _buildProfileContent(
            context,
            displayName: displayName,
            email: email,
            role: role,
            isAdmin: isAdmin,
          );
        },
      ),
    );
  }

  Widget _buildNotAuthenticated(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_circle,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            const Text(
              'No has iniciado sesión',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Elige cómo quieres acceder',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // Opción 1: Login de usuario normal
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context)
                      .push(RouteTransitions.fadeScale(const LoginScreen()));
                },
                icon: const Icon(Icons.person),
                label: const Text('Iniciar sesión como usuario'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Opción 2: Login de admin (botón flotante)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context)
                      .push(RouteTransitions.fadeScale(const AdminLoginPage()));
                },
                icon: const Icon(Icons.admin_panel_settings),
                label: const Text('Acceder como administrador'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.blue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                    RouteTransitions.fadeScale(const RegistrationScreen()));
              },
              child: const Text('¿No tienes cuenta? Regístrate'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context, {
    required String displayName,
    required String email,
    required String role,
    required bool isAdmin,
  }) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header con avatar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.blueGrey[800],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isAdmin ? Colors.purple : Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    role.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Opciones del perfil
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildMenuItem(
                  icon: Icons.receipt_long,
                  title: 'Mis Pedidos',
                  subtitle: 'Historial de tus compras',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.of(context).push(
                        RouteTransitions.slideFromRight(const MyOrdersPage()));
                  },
                ),
                _buildMenuItem(
                  icon: Icons.favorite,
                  title: 'Favoritos',
                  subtitle: 'Productos que te gustan',
                  color: Colors.red,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Próximamente'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.location_on,
                  title: 'Direcciones',
                  subtitle: 'Gestiona tus direcciones',
                  color: Colors.green,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Próximamente'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.payment,
                  title: 'Métodos de Pago',
                  subtitle: 'Tarjetas y preferencias',
                  color: Colors.purple,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Próximamente'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  icon: Icons.settings,
                  title: 'Configuración',
                  subtitle: 'Preferencias de la app',
                  color: Colors.grey,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Próximamente'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                if (isAdmin) ...[
                  const Divider(height: 32),
                  _buildMenuItem(
                    icon: Icons.admin_panel_settings,
                    title: 'Panel de Administración',
                    subtitle: 'Gestiona la plataforma',
                    color: Colors.purple,
                    onTap: () {
                      Navigator.of(context).push(
                          RouteTransitions.fadeScale(const AdminPanelPage()));
                    },
                  ),
                ],
                const Divider(height: 32),
                _buildMenuItem(
                  icon: Icons.logout,
                  title: 'Cerrar Sesión',
                  subtitle: 'Salir de tu cuenta',
                  color: Colors.red,
                  onTap: () {
                    _showLogoutDialog(context);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                context.read<AuthBloc>().add(AuthLogoutRequested());
                Navigator.pop(context);
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );
  }
}
