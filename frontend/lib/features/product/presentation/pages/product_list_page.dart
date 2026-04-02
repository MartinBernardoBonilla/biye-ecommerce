import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:biye/features/product/data/models/product_model.dart';
import 'package:biye/features/product/data/services/product_service.dart';
import 'package:biye/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:biye/features/cart/presentation/bloc/cart_event.dart';
import 'package:biye/features/cart/domain/entities/cart_item.dart';
import 'package:biye/core/utils/overlay_helper.dart';
import 'package:biye/core/widgets/custom_toast.dart';
import 'package:biye/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:biye/features/favorites/presentation/bloc/favorites_event.dart';
import 'package:biye/features/favorites/presentation/bloc/favorites_state.dart';
import 'package:biye/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:biye/features/auth/presentation/bloc/auth_state.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  String _getImageUrl() {
    if (product.image?.url.isNotEmpty == true) {
      return product.image!.url;
    }
    return 'https://res.cloudinary.com/dwchpxcrv/image/upload/default-product_zbscxc.png';
  }

  @override
  Widget build(BuildContext context) {
    final String displayPrice = '\$${product.price.toStringAsFixed(0)}';
    final String imageUrl = _getImageUrl();

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: GestureDetector(
                onTap: () {
                  print(
                      '🖱️ Click en producto: ${product.name} (ID: ${product.id})');
                  Navigator.pushNamed(
                    context,
                    '/product-detail',
                    arguments: product.id,
                  );
                },
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image, size: 40),
                          );
                        },
                      ),
                    ),
                    // ✅ BOTÓN DE FAVORITOS AGREGADO
                    Positioned(
                      top: 8,
                      right: 8,
                      child: BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, authState) {
                          final isLoggedIn = authState is AuthAuthenticated ||
                              authState is AuthTokenAuthenticated;

                          return BlocBuilder<FavoritesBloc, FavoritesState>(
                            buildWhen: (previous, current) {
                              if (current is FavoriteStatus &&
                                  current.productId == product.id) {
                                return true;
                              }
                              if (current is FavoritesLoaded &&
                                  previous is! FavoritesLoaded) {
                                return true;
                              }
                              return false;
                            },
                            builder: (context, state) {
                              bool isFavorite = false;

                              if (state is FavoriteStatus &&
                                  state.productId == product.id) {
                                isFavorite = state.isFavorite;
                              } else if (state is FavoritesLoaded) {
                                isFavorite = state.favorites
                                    .any((f) => f.productId == product.id);
                              }

                              return MouseRegion(
                                cursor: isLoggedIn
                                    ? SystemMouseCursors.click
                                    : SystemMouseCursors.basic,
                                child: GestureDetector(
                                  onTap: isLoggedIn
                                      ? () {
                                          print(
                                              '❤️ Tap en corazón de ${product.name}');
                                          final favoritesBloc =
                                              context.read<FavoritesBloc>();

                                          if (isFavorite) {
                                            favoritesBloc.add(RemoveFavorite(
                                                productId: product.id));
                                          } else {
                                            favoritesBloc.add(AddFavorite(
                                              productId: product.id,
                                              productName: product.name,
                                              productPrice: product.price,
                                              productImage: imageUrl,
                                            ));
                                          }
                                        }
                                      : () {
                                          CustomToast.action(
                                            context: context,
                                            message:
                                                'Inicia sesión para agregar a favoritos',
                                            actionLabel: 'INICIAR',
                                            onAction: () {
                                              Navigator.pushNamed(
                                                  context, '/login');
                                            },
                                            duration:
                                                const Duration(seconds: 3),
                                            backgroundColor:
                                                Colors.blueGrey[800]!,
                                          );
                                        },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isFavorite
                                          ? Colors.red
                                          : (isLoggedIn
                                              ? Colors.grey
                                              : Colors.grey[400]),
                                      size: 20,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          displayPrice,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 16,
                          ),
                        ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              print(
                                  '🟢 Botón de carrito TOCADO para ${product.name}');

                              final cartItem = CartItem(
                                id: product.id ?? '',
                                name: product.name,
                                price: product.price,
                                quantity: 1,
                                imageUrl: imageUrl,
                                description: product.description,
                              );
                              context.read<CartBloc>().add(AddToCart(cartItem));

                              OverlayHelper.showAddedToCart(
                                context: context,
                                productName: product.name,
                                onViewCart: () =>
                                    Navigator.pushNamed(context, '/cart'),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.yellow.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.add_shopping_cart,
                                size: 24,
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
          ],
        ),
      ),
    );
  }
}

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  static const String routeName = '/products';

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final ProductService _productService = ProductService();
  List<ProductModel> _products = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final products = await _productService.fetchProducts();
      if (mounted) {
        setState(() {
          _products = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProducts,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_products.isEmpty) {
      return const Center(child: Text('No hay productos disponibles'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        return ProductCard(product: _products[index]);
      },
    );
  }
}
