import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:biye/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:biye/features/auth/presentation/bloc/auth_state.dart';
import 'package:biye/features/auth/presentation/bloc/auth_event.dart';
import 'package:biye/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:biye/features/cart/presentation/bloc/cart_state.dart';

// Páginas principales (Bottom Nav)
import 'package:biye/features/home/presentation/home_screen.dart';
import 'package:biye/features/product/presentation/pages/product_list_page.dart';
import 'package:biye/features/profile/presentation/pages/profile_page.dart';

// Páginas secundarias (Drawer)
import 'package:biye/features/order/presentation/pages/my_orders_page.dart';
import 'package:biye/features/auth/presentation/login_screen.dart';

class PersistentBottomNav extends StatefulWidget {
  final Widget child;

  const PersistentBottomNav({super.key, required this.child});

  @override
  State<PersistentBottomNav> createState() => _PersistentBottomNavState();
}

class _PersistentBottomNavState extends State<PersistentBottomNav> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Páginas para el IndexedStack
  late final List<Widget> _pages = [
    const HomeScreen(),
    const ProductListPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    // No hacer nada aquí que dependa del contexto
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Programar la actualización para después del build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateIndexFromRoute();
    });
  }

  // ✅ SOLO UNA DEFINICIÓN DE ESTE MÉTODO
  void _updateIndexFromRoute() {
    if (!mounted) return;

    final routeName = ModalRoute.of(context)?.settings.name;
    if (routeName == null) return;

    int newIndex = 0;
    switch (routeName) {
      case '/products':
        newIndex = 1;
        break;
      case '/profile':
        newIndex = 2;
        break;
      case '/':
      default:
        newIndex = 0;
    }

    if (_selectedIndex != newIndex) {
      setState(() {
        _selectedIndex = newIndex;
      });
    }
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openMenu() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          // 👈 QUITAR 'const'
          'BIYE',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26,
            letterSpacing: 2,
            foreground: Paint()
              ..shader = LinearGradient(
                colors: [
                  Colors.yellow,
                  const Color(0xFFFFD700)
                ], // Solo 'const' aquí
                stops: const [0.3, 0.8], // Y aquí
              ).createShader(const Rect.fromLTWH(0, 0, 150, 50)),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.yellow, size: 28),
          onPressed: _openMenu,
        ),
        actions: [
          // Carrito con animación (esto está bien)
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0.8, end: 1.0),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.elasticOut,
                    builder: (context, double scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: IconButton(
                          icon: const Icon(Icons.shopping_cart,
                              color: Colors.yellow, size: 28),
                          onPressed: () =>
                              Navigator.pushNamed(context, '/cart'),
                        ),
                      );
                    },
                  ),
                  if (state.items.isNotEmpty)
                    if (state.items.isNotEmpty)
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0.5, end: 1.0),
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.elasticOut,
                        builder: (context, double scale, child) {
                          return Positioned(
                            // ✅ El Positioned AHORA es el primer hijo
                            right: 4,
                            top: 4,
                            child: Transform.scale(
                              scale: scale,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '${state.items.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
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
              icon: Icon(Icons.person, size: 28), label: 'Perfil'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 8,
        selectedFontSize: 14,
        unselectedFontSize: 12,
        onTap: _onBottomNavTapped,
      ),
      drawer: Drawer(
        child: Container(
          color: Colors.blueGrey[900],
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blueGrey[800],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.yellow,
                      child: Icon(Icons.person, color: Colors.black),
                    ),
                    const SizedBox(height: 10),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        String userName = 'Usuario';
                        if (state is AuthAuthenticated) {
                          userName = state.user.displayName ?? 'Usuario';
                        }
                        return Text(
                          'Hola, $userName',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.receipt_long,
                    color: Colors.yellow, size: 28),
                title: const Text('Mis Pedidos',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/my-orders');
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.settings, color: Colors.yellow, size: 28),
                title: const Text('Configuración',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Próximamente')),
                  );
                },
              ),
              const Divider(color: Colors.white24),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthAuthenticated) {
                    return ListTile(
                      leading: const Icon(Icons.logout,
                          color: Colors.yellow, size: 28),
                      title: const Text('Cerrar Sesión',
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                      onTap: () {
                        Navigator.pop(context);
                        context.read<AuthBloc>().add(AuthLogoutRequested());
                      },
                    );
                  }
                  return ListTile(
                    leading:
                        const Icon(Icons.login, color: Colors.yellow, size: 28),
                    title: const Text('Iniciar Sesión',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/login');
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
