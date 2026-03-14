import 'package:biye/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:biye/features/auth/presentation/bloc/auth_event.dart';
import 'package:biye/features/auth/presentation/bloc/auth_state.dart';
import 'package:biye/features/product/presentation/pages/product_list_page.dart';
import 'package:biye/features/product/presentation/pages/product_detail_page.dart';

import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:biye/features/auth/presentation/registration_screen.dart';
import 'package:biye/features/auth/presentation/login_screen.dart';

// Importaciones del Carrito
import 'package:biye/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:biye/features/cart/presentation/bloc/cart_state.dart';
import 'package:biye/features/cart/presentation/bloc/cart_event.dart';
import 'package:biye/features/cart/presentation/pages/enhanced_cart_page.dart';
import 'package:biye/features/cart/domain/entities/cart_item.dart';

// Importaciones de admin y productos
import 'package:biye/features/admin/presentation/pages/admin_login_page.dart';
import 'package:biye/features/product/data/models/product_model.dart';
import 'package:biye/features/product/data/services/product_service.dart';

import 'package:biye/core/utils/route_transitions.dart';
import 'package:biye/features/profile/presentation/pages/profile_page.dart';

// ------------------------------------------------------------------
// GLASSMORPHISM CARD (con navegación a detalle y cursor clickeable)
// ------------------------------------------------------------------
class GlassmorphismCard extends StatelessWidget {
  final ProductModel product;

  const GlassmorphismCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final String displayPrice = '\$${product.price.toStringAsFixed(0)}';
    final String imageUrl = product.image?.url ??
        'https://placehold.co/150x150/cccccc/333333?text=NO+IMG';

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          print(
              '🖱️ Click en producto desde Home: ${product.name} (ID: ${product.id})');
          Navigator.of(context).push(
            RouteTransitions.fadeScale(
              ProductDetailPage(productId: product.id),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15.0),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Center(
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey[300]!,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: imageUrl.toLowerCase().endsWith('.svg')
                                ? SvgPicture.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    placeholderBuilder: (context) => Container(
                                      color: Colors.grey[300]!,
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: Colors.grey[300]!,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Colors.grey,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[300]!,
                                        child: Icon(
                                          Icons.shopping_bag,
                                          size: 35,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          displayPrice,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              final cartItem = CartItem(
                                id: product.id ?? 'no-id',
                                name: product.name,
                                price: product.price,
                                quantity: 1,
                                imageUrl: imageUrl,
                                description: product.description,
                              );
                              context.read<CartBloc>().add(AddToCart(cartItem));

                              // Primero declaramos la variable
                              late OverlayEntry overlayEntry;

                              // Luego creamos el overlayEntry
                              overlayEntry = OverlayEntry(
                                builder: (context) => Positioned(
                                  bottom: 80,
                                  left: 20,
                                  right: 20,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${product.name} agregado',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              overlayEntry.remove();
                                              Navigator.pushNamed(
                                                  context, '/cart');
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: const Text(
                                                'VER',
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );

                              // Mostrar el overlay
                              Overlay.of(context).insert(overlayEntry);

                              // Auto-remover después de 3 segundos
                              Future.delayed(const Duration(seconds: 3), () {
                                if (overlayEntry.mounted) {
                                  overlayEntry.remove();
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.yellow.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.add_shopping_cart,
                                size: 20,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  bool _isMenuOpen = false;

  List<ProductModel> _products = [];
  bool _isLoading = true;
  final ProductService _productService = ProductService();

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthStarted());
    _fetchProducts();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: -300.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _fetchProducts() async {
    try {
      final fetchedProducts = await _productService.fetchProducts();
      if (mounted) {
        setState(() {
          _products = fetchedProducts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al cargar productos.'),
              backgroundColor: Colors.red,
            ),
          );
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
      if (_isMenuOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Próximamente'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.blueGrey[800],
      ),
    );
  }

  Widget _buildAdBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      height: 78,
      decoration: BoxDecoration(
        color: Colors.grey[800]!,
        borderRadius: BorderRadius.circular(15.0),
      ),
      alignment: Alignment.center,
      child: const Text(
        '¡Aquí va tu Publicidad!',
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }

  Widget _buildProductGrid(int startIndex, int count) {
    final List<ProductModel> sublist =
        _products.sublist(startIndex, startIndex + count);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sublist.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        return GlassmorphismCard(product: sublist[index]);
      },
    );
  }

  List<Widget> _buildProductsWithAds() {
    List<Widget> widgets = [];
    final int productCount = _products.length;

    if (productCount == 0 && !_isLoading) {
      widgets.add(
        const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text(
              "No se encontraron productos.",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      );
      widgets.add(_buildAdBanner());
      return widgets;
    }

    int productsProcessed = 0;
    while (productsProcessed < productCount) {
      final int count = (productCount - productsProcessed) > 6
          ? 6
          : (productCount - productsProcessed);
      widgets.add(_buildProductGrid(productsProcessed, count));
      productsProcessed += count;
      if (productsProcessed < productCount) {
        widgets.add(const SizedBox(height: 20));
        widgets.add(_buildAdBanner());
        widgets.add(const SizedBox(height: 20));
      }
    }
    widgets.add(const SizedBox(height: 20));
    return widgets;
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.yellow, size: 24),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/marmolamarillo.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(
                height: AppBar().preferredSize.height +
                    MediaQuery.of(context).padding.top,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        _isLoading
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(50.0),
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.yellow,
                                    ),
                                  ),
                                ),
                              )
                            : Column(children: _buildProductsWithAds()),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          AnimatedBuilder(
            animation: _slideAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_slideAnimation.value, 0),
                child: Container(
                  width: 300,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.9),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 20,
                        offset: Offset(5, 0),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: Colors.yellow.withOpacity(0.1),
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.yellow.withOpacity(0.3),
                              ),
                            ),
                          ),
                          child: BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              String userName = 'Usuario';
                              if (state is AuthAuthenticated) {
                                userName = state.user.displayName ?? 'Usuario';
                              }
                              return Row(
                                children: [
                                  const CircleAvatar(
                                    backgroundColor: Colors.yellow,
                                    child:
                                        Icon(Icons.person, color: Colors.black),
                                  ),
                                  const SizedBox(width: 15),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Bienvenido',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        userName,
                                        style: const TextStyle(
                                            color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            children: [
                              _buildMenuItem(Icons.home, 'Inicio', _toggleMenu),
                              _buildMenuItem(Icons.shopping_bag, 'Productos',
                                  () {
                                _toggleMenu();
                                Navigator.of(context).push(
                                    RouteTransitions.slideFromRight(
                                        const ProductListPage()));
                              }),
                              _buildMenuItem(Icons.favorite, 'Favoritos', () {
                                _toggleMenu();
                                _showComingSoon(context, 'Favoritos');
                              }),
                              _buildMenuItem(Icons.receipt_long, 'Mis Pedidos',
                                  () {
                                _toggleMenu();
                                Navigator.pushNamed(context, '/my-orders');
                              }),
                              const Divider(color: Colors.white24),
                              _buildMenuItem(Icons.person, 'Perfil', () {
                                _toggleMenu();
                                final authState =
                                    context.read<AuthBloc>().state;
                                if (authState is AuthAuthenticated) {
                                  Navigator.of(context).push(
                                      RouteTransitions.fadeScale(
                                          const ProfilePage()));
                                } else {
                                  Navigator.of(context).push(
                                      RouteTransitions.fadeScale(
                                          const LoginScreen()));
                                }
                              }),
                              _buildMenuItem(Icons.logout, 'Cerrar Sesión', () {
                                _toggleMenu();
                                context
                                    .read<AuthBloc>()
                                    .add(AuthLogoutRequested());
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          if (_isMenuOpen)
            GestureDetector(
              onTap: _toggleMenu,
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<AuthBloc>().add(AuthCheckStatus());
          Future.delayed(const Duration(milliseconds: 100), () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminLoginPage()),
            );
          });
        },
        backgroundColor: Colors.blueGrey[800]!,
        child: const Icon(Icons.admin_panel_settings, color: Colors.white),
      ),
    );
  }
}
