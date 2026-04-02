import 'package:biye/core/utils/overlay_helper.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/modern_card.dart';
import '../../../../core/widgets/network_image_with_placeholder.dart';
import '../../data/models/product_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:biye/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:biye/features/cart/presentation/bloc/cart_event.dart';
import 'package:biye/features/cart/domain/entities/cart_item.dart';

// 👇 IMPORTS PARA FAVORITOS
import 'package:biye/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:biye/features/favorites/presentation/bloc/favorites_event.dart';
import 'package:biye/features/favorites/presentation/bloc/favorites_state.dart';
import 'package:biye/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:biye/features/auth/presentation/bloc/auth_state.dart';
import 'package:biye/core/widgets/custom_toast.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final bool showDetails;
  final double? width;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.showDetails = true,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth = width ?? MediaQuery.of(context).size.width * 0.45;

    return SizedBox(
      width: cardWidth,
      child: ModernCard(
        onTap: onTap,
        padding: EdgeInsets.zero,
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del producto con botón de favoritos
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  child: NetworkImageWithPlaceholder(
                    imageUrl: product.image?.url ?? '',
                    width: double.infinity,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                // Botón de favoritos - USANDO BLoC GLOBAL
                Positioned(
                  top: 8,
                  right: 8,
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, authState) {
                      final isLoggedIn = authState is AuthAuthenticated ||
                          authState is AuthTokenAuthenticated;

                      // ✅ Usar BlocBuilder con buildWhen para solo FavoriteStatus
                      return BlocBuilder<FavoritesBloc, FavoritesState>(
                        buildWhen: (previous, current) {
                          // Solo reconstruir cuando es FavoriteStatus del producto actual
                          if (current is FavoriteStatus &&
                              current.productId == product.id) {
                            return true;
                          }
                          // También reconstruir cuando se carga la lista completa (para estado inicial)
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
                                          productImage:
                                              product.image?.url ?? '',
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
                                        duration: const Duration(seconds: 3),
                                        backgroundColor: Colors.blueGrey[800]!,
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
            if (showDetails) ...[
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            product.category,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.inventory_2,
                              size: 12,
                              color: product.countInStock > 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${product.countInStock}',
                              style: TextStyle(
                                fontSize: 12,
                                color: product.countInStock > 0
                                    ? Colors.green
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      onEnter: (_) => print(
                          '🟡 MOUSE ENTER - BOTÓN CARRITO ${product.name}'),
                      onExit: (_) => print(
                          '🟡 MOUSE EXIT - BOTÓN CARRITO ${product.name}'),
                      child: GestureDetector(
                        onTap: () {
                          print('👆 TAP EN BOTÓN CARRITO ${product.name}');
                          final cartItem = CartItem(
                            id: product.id,
                            name: product.name,
                            price: product.price,
                            quantity: 1,
                            imageUrl: product.image?.url ?? '',
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
                          width: double.infinity,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'Añadir al carrito',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
