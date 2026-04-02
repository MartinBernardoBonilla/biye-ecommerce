import 'package:biye/core/services/navigation_service.dart';
import 'package:biye/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:biye/features/home/presentation/home_screen.dart';
import 'package:biye/features/product/presentation/pages/product_list_page.dart';
import 'package:biye/features/profile/presentation/pages/profile_page.dart';
import 'package:biye/features/favorites/presentation/pages/favorites_page.dart';
import 'package:biye/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:biye/features/cart/presentation/bloc/cart_state.dart';
import 'package:biye/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:biye/features/auth/presentation/bloc/auth_state.dart';
import 'package:provider/provider.dart';
import '../../core/providers/theme_provider.dart';

class PersistentBottomNav extends StatefulWidget {
  const PersistentBottomNav({super.key});

  @override
  State<PersistentBottomNav> createState() => _PersistentBottomNavState();
}

class _PersistentBottomNavState extends State<PersistentBottomNav> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _pages = [
    const HomeScreen(),
    const ProductListPage(),
    const FavoritesPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    // Escuchar cambios en NavigationService
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navService = context.read<NavigationService>();
      navService.addListener(() {
        if (mounted) {
          setState(() {
            _selectedIndex = navService.currentIndex;
          });
        }
      });
    });
  }

  void _onItemTapped(int index) {
    print('🔵 [NAV] Cambiando a pestaña: $index');
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });
  }

  void _openMenu() {
    _scaffoldKey.currentState?.openDrawer();
  }

  // ✅ MÉTODO PARA CONSTRUIR ÍTEMS DEL DRAWER
  Widget _buildDrawerItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    final isSelected = _selectedIndex == _getIndexFromLabel(label);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color:
              isSelected ? Colors.yellow.withOpacity(0.2) : Colors.transparent,
        ),
        child: ListTile(
          leading: Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? Colors.yellow : (iconColor ?? Colors.white70),
            size: 24,
          ),
          title: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.yellow : Colors.white,
            ),
          ),
          trailing: isSelected
              ? Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(2),
                  ),
                )
              : null,
          onTap: onTap,
        ),
      ),
    );
  }

  // ✅ MÉTODO PARA OBTENER ÍNDICE SEGÚN LA ETIQUETA
  int _getIndexFromLabel(String label) {
    switch (label) {
      case 'Inicio':
        return 0;
      case 'Productos':
        return 1;
      case 'Favoritos':
        return 2;
      case 'Mi Perfil':
        return 3;
      default:
        return -1;
    }
  }

  // ✅ MÉTODO PARA MOSTRAR DIÁLOGO DE CONFIRMACIÓN
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AuthBloc>().add(AuthLogoutRequested());
              Navigator.pop(context);
              _onItemTapped(0);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('🏠 [PERSISTENT] Pestaña actual: $_selectedIndex');

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('BIYE',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 26,
                color: Colors.yellow)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.yellow, size: 28),
          onPressed: _openMenu,
        ),
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart,
                        color: Colors.yellow, size: 28),
                    onPressed: () => Navigator.pushNamed(context, '/cart'),
                  ),
                  if (state.items.isNotEmpty)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle),
                        child: Text('${state.items.length}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12)),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 28), label: 'Inicio'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag, size: 28), label: 'Productos'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite, size: 28), label: 'Favoritos'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 28), label: 'Perfil'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
        unselectedLabelStyle: const TextStyle(
          color: Colors.grey,
        ),
        backgroundColor: Colors.white,
        elevation: 8,
        onTap: _onItemTapped,
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blueGrey[900]!,
                Colors.blueGrey[800]!,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header del drawer - elegante
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.yellow[700]!,
                        Colors.amber[600]!,
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                    ),
                  ),
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      String userName = 'Usuario';
                      String userEmail = '';

                      if (state is AuthAuthenticated) {
                        userName = state.user.displayName ??
                            state.user.email?.split('@').first ??
                            'Usuario';
                        userEmail = state.user.email ?? '';
                      } else if (state is AuthTokenAuthenticated) {
                        userName = state.userData['username'] ??
                            state.userData['email']?.split('@').first ??
                            'Usuario';
                        userEmail = state.userData['email'] ?? '';
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.white,
                            child: Text(
                              userName.isNotEmpty
                                  ? userName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (userEmail.isNotEmpty)
                            Text(
                              userEmail,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Menú items
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildDrawerItem(
                        icon: Icons.home_outlined,
                        activeIcon: Icons.home,
                        label: 'Inicio',
                        onTap: () {
                          Navigator.pop(context);
                          _onItemTapped(0);
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.shopping_bag_outlined,
                        activeIcon: Icons.shopping_bag,
                        label: 'Productos',
                        onTap: () {
                          Navigator.pop(context);
                          _onItemTapped(1);
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.favorite_outline,
                        activeIcon: Icons.favorite,
                        label: 'Favoritos',
                        onTap: () {
                          Navigator.pop(context);
                          _onItemTapped(2);
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.receipt_outlined,
                        activeIcon: Icons.receipt,
                        label: 'Mis Pedidos',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/my-orders');
                        },
                      ),
                      // ✅ AGREGAR SWITCH PARA MODO OSCURO/CLARO
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Consumer<ThemeProvider>(
                          builder: (context, themeProvider, child) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white.withOpacity(0.1),
                              ),
                              child: SwitchListTile(
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                title: Row(
                                  children: [
                                    Icon(
                                      themeProvider.isDarkMode
                                          ? Icons.dark_mode
                                          : Icons.light_mode,
                                      color: Colors.yellow,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      themeProvider.isDarkMode
                                          ? 'Modo Oscuro'
                                          : 'Modo Claro',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                value: themeProvider.isDarkMode,
                                onChanged: (_) => themeProvider.toggleTheme(),
                                activeThumbColor: Colors.yellow,
                                inactiveThumbColor: Colors.grey,
                                inactiveTrackColor: Colors.white24,
                              ),
                            );
                          },
                        ),
                      ),
                      const Divider(
                        color: Colors.white24,
                        thickness: 1,
                        indent: 20,
                        endIndent: 20,
                      ),
                      _buildDrawerItem(
                        icon: Icons.person_outline,
                        activeIcon: Icons.person,
                        label: 'Mi Perfil',
                        onTap: () {
                          Navigator.pop(context);
                          _onItemTapped(3);
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.logout,
                        activeIcon: Icons.logout,
                        label: 'Cerrar Sesión',
                        iconColor: Colors.redAccent,
                        onTap: () {
                          Navigator.pop(context);
                          _showLogoutDialog(context);
                        },
                      ),
                    ],
                  ),
                ),

                // Footer con versión
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Biye v1.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
