import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:biye/features/auth/presentation/registration_screen.dart';
import 'package:biye/features/auth/presentation/login_screen.dart';

// Importaciones del Carrito (existentes)
import 'package:biye/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:biye/features/cart/presentation/bloc/cart_state.dart';
import 'package:biye/features/cart/presentation/bloc/cart_event.dart';
import 'package:biye/features/cart/presentation/pages/enhanced_cart_page.dart';
import 'package:biye/features/cart/domain/entities/cart_item.dart';

// Importaciones del NUEVO servicio de productos (CRÍTICO)
import 'package:biye/features/admin/presentation/pages/admin_login_page.dart';
import 'package:biye/features/product/data/models/product_model.dart'; // Tu modelo real
import 'package:biye/features/product/data/services/product_service.dart';

// ❌ ELIMINADA IMPORTACIÓN DUPLICADA: import 'package:biye/features/product/data/models/product_model.dart';

// ------------------------------------------------------------------
// ✅ WIDGET GLASSMORPHISM CARD (Actualizado para ProductModel)
// ------------------------------------------------------------------
class GlassmorphismCard extends StatelessWidget {
  final ProductModel product;

  const GlassmorphismCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // DEBUG
    print('🖼️ GlassmorphismCard para: ${product.name}');
    print('   URL: ${product.image?.url}');

    final String displayPrice = '\$${product.price.toStringAsFixed(0)}';
    final String imageUrl = product.image?.url ??
        'https://placehold.co/150x150/cccccc/333333?text=NO+IMG';

    print('   Usando URL: $imageUrl');

    return ClipRRect(
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
                      width: double.infinity, // ✅ AÑADIR ESTO
                      height: double.infinity, // ✅ AÑADIR ESTO
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[300]!,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover, // ✅ Asegurar que cubra
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              print('   ✅ Imagen cargada: ${product.name}');
                              return child;
                            }
                            print('   🔄 Cargando: ${product.name}');
                            return Container(
                              color: Colors.grey[300]!,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.grey,
                                  ),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            print(
                              '   ❌ Error imagen: ${product.name} - $error',
                            );
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
                    GestureDetector(
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

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${product.name} agregado al carrito',
                            ),
                            duration: const Duration(seconds: 2),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.yellow.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.add_shopping_cart,
                          size: 12,
                          color: Colors.black,
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
    );
  }
}

// ------------------------------------------------------------------
// CLASE PRODUCT: Eliminamos el modelo hardcodeado y usamos el real.
// Opcionalmente, puedes dejar esto como un typedef si necesitas usar 'Product'
// en otros lugares, pero en esta pantalla ya usamos ProductModel directamente.
// ------------------------------------------------------------------

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

  // ------------------------------------------------------------------
  // ✅ ESTADO PARA CARGAR PRODUCTOS
  // ------------------------------------------------------------------
  List<ProductModel> _products = [];
  bool _isLoading = true;
  final ProductService _productService = ProductService();

  @override
  void initState() {
    super.initState();
    _fetchProducts(); // Llama a la API al iniciar

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: -300.0, // Menú oculto fuera de pantalla
      end: 0.0, // Menú visible
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  // ------------------------------------------------------------------
  // ✅ FUNCIÓN PARA CARGAR PRODUCTOS DESDE LA API
  // ------------------------------------------------------------------
  Future<void> _fetchProducts() async {
    try {
      final fetchedProducts = await _productService.fetchProducts();
      if (mounted) {
        setState(() {
          _products = fetchedProducts; // ✅ CORREGIDO: usa fetchedProducts
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Manejar error (e.g., mostrar un mensaje)
          print("Error al cargar productos: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al cargar productos. Revisa tu backend.'),
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Widget para la publicidad (sin cambios)
  Widget _buildAdBanner() {
    const double adHeight = 78.0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      height: adHeight,
      decoration: BoxDecoration(
        color: Colors.grey[800]!,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Text(
        '¡Aquí va tu Publicidad!',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ------------------------------------------------------------------
  // ✅ FUNCIÓN SIMPLE PARA CONSTRUIR PRODUCTOS CON PUBLICIDADES INTERCALADAS
  // (Ahora usa la lista _products cargada de la API)
  // ------------------------------------------------------------------
  List<Widget> _buildProductsWithAds() {
    List<Widget> widgets = [];
    final int productCount = _products.length;

    // Si no hay productos, no hay nada que mostrar (excepto el banner)
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

    // Intercalar productos y publicidad cada 6 items
    int productsProcessed = 0;
    while (productsProcessed < productCount) {
      final int remaining = productCount - productsProcessed;
      final int count = remaining > 6 ? 6 : remaining;

      widgets.add(_buildProductGrid(productsProcessed, count));
      productsProcessed += count;

      if (productsProcessed < productCount) {
        widgets.add(const SizedBox(height: 20));
        widgets.add(_buildAdBanner());
        widgets.add(const SizedBox(height: 20));
      }
    }

    widgets.add(const SizedBox(height: 20)); // Espacio final

    return widgets;
  }

  // ------------------------------------------------------------------
  // ✅ FUNCIÓN PARA CONSTRUIR EL GRID (Ahora usa la lista _products)
  // ------------------------------------------------------------------
  Widget _buildProductGrid(int startIndex, int count) {
    // Usamos el sublist para obtener solo los productos que necesitamos para este grid
    final List<ProductModel> sublist = _products.sublist(
      startIndex,
      startIndex + count,
    );

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sublist.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 productos por fila para smartphone
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        childAspectRatio: 0.85, // Un poco más alto que ancho
      ),
      itemBuilder: (context, index) {
        return GlassmorphismCard(product: sublist[index]);
      },
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    // ... (sin cambios)
    return ListTile(
      leading: Icon(icon, color: Colors.yellow, size: 24),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      hoverColor: Colors.yellow.withOpacity(0.1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double scaleFactor = 1.75;

    return Scaffold(
      body: Stack(
        children: [
          // Fondo con imagen de mármol
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/marmolamarillo.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Contenido principal
          Column(
            children: [
              // AppBar fija
              Container(
                height: AppBar().preferredSize.height * scaleFactor +
                    MediaQuery.of(context).padding.top,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Botón hamburguesa/X animado empujado por el menú
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        double pushDistance = (_animationController.value * 80);

                        return Transform.translate(
                          offset: Offset(pushDistance, 0),
                          child: IconButton(
                            icon: Stack(
                              alignment: Alignment.center,
                              children: [
                                Opacity(
                                  opacity: 1 - _animationController.value,
                                  child: Transform.rotate(
                                    angle:
                                        _animationController.value * -0.785398,
                                    child: Icon(
                                      Icons.menu,
                                      color: Colors.yellow,
                                      size: 24 * scaleFactor,
                                    ),
                                  ),
                                ),
                                Opacity(
                                  opacity: _animationController.value,
                                  child: Transform.rotate(
                                    angle:
                                        _animationController.value * 0.785398,
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.yellow,
                                      size: 24 * scaleFactor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onPressed: _toggleMenu,
                          ),
                        );
                      },
                    ),

                    // Título centrado
                    Expanded(
                      child: Center(
                        child: Text(
                          'Biye',
                          style: TextStyle(
                            color: Colors.yellow,
                            fontWeight: FontWeight.bold,
                            fontSize: 20 * scaleFactor,
                          ),
                        ),
                      ),
                    ),

                    // Icono del carrito con badge
                    BlocBuilder<CartBloc, CartState>(
                      builder: (context, state) {
                        return Stack(
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.shopping_cart,
                                color: Colors.yellow,
                                size: 24 * scaleFactor,
                              ),
                              onPressed: () {
                                // NOTA: Asumimos que CartPage existe en el path correcto.
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const CartPage(), // Usamos CartPage según el import
                                  ),
                                );
                              },
                            ),
                            if (state.items.isNotEmpty)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    '${state.items.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.person,
                        color: Colors.yellow,
                        size: 24 * scaleFactor,
                      ),
                      onSelected: (String result) {
                        if (result == 'register') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegistrationScreen(),
                            ),
                          );
                        } else if (result == 'login') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'login',
                          child: Text('Iniciar sesión'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'register',
                          child: Text('Registrarse'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Contenido desplazable con productos y publicidad
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        // Espacio inicial
                        SizedBox(
                          height: MediaQuery.of(context).size.height *
                              0.08, // Reducido el espacio
                          child: const Center(child: SizedBox.shrink()),
                        ),

                        // ------------------------------------------------------------------
                        // ✅ CARGADOR O PRODUCTOS
                        // ------------------------------------------------------------------
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

          // Menú deslizante
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(5, 0),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header del menú
                        Container(
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: Colors.yellow.withOpacity(0.1),
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.yellow.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                          ),
                          child: const Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.yellow,
                                child: Icon(Icons.person, color: Colors.black),
                              ),
                              SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bienvenido',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Usuario',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Opciones del menú
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            children: [
                              _buildMenuItem(Icons.home, 'Inicio', () {
                                _toggleMenu();
                              }),
                              _buildMenuItem(
                                Icons.shopping_bag,
                                'Productos',
                                () {
                                  _toggleMenu();
                                },
                              ),
                              _buildMenuItem(Icons.favorite, 'Favoritos', () {
                                _toggleMenu();
                              }),
                              _buildMenuItem(
                                Icons.shopping_cart,
                                'Carrito',
                                () {
                                  _toggleMenu();
                                  // Navegar al carrito desde el menú también
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const CartPage(),
                                    ),
                                  );
                                },
                              ),
                              _buildMenuItem(Icons.history, 'Historial', () {
                                _toggleMenu();
                              }),
                              const Divider(color: Colors.white24),
                              _buildMenuItem(
                                Icons.settings,
                                'Configuración',
                                () {
                                  _toggleMenu();
                                },
                              ),
                              _buildMenuItem(Icons.help_outline, 'Ayuda', () {
                                _toggleMenu();
                              }),
                              _buildMenuItem(Icons.logout, 'Cerrar Sesión', () {
                                _toggleMenu();
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

          // Overlay para cerrar el menú al tocar fuera
          if (_isMenuOpen)
            GestureDetector(
              onTap: _toggleMenu,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                width: double.infinity,
                height: double.infinity,
              ),
            ),
        ],
      ),
      // ✅ AGREGA ESTO - BOTÓN FLOTANTE PARA ADMIN
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            // 🟢 CORRECCIÓN: Se añade 'const' para resolver advertencias y mejorar rendimiento
            MaterialPageRoute(builder: (context) => const AdminLoginPage()),
          );
        },
        backgroundColor: Colors.blueGrey[800]!,
        child: const Icon(Icons.admin_panel_settings, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // Barra de navegación inferior fija (sin cambios)
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Productos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }
}
