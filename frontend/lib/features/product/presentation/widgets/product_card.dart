// lib/features/product/presentation/widgets/product_card.dart
import 'package:flutter/material.dart';
import '../../../../core/widgets/modern_card.dart';
import '../../../../core/widgets/network_image_with_placeholder.dart';
import '../../data/models/product_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:biye/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:biye/features/cart/presentation/bloc/cart_event.dart';
import 'package:biye/features/cart/domain/entities/cart_item.dart';

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
            // Imagen del producto
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: NetworkImageWithPlaceholder(
                imageUrl: product.image?.url ?? '',
                width: double.infinity,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),

            if (showDetails) ...[
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre del producto
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

                    SizedBox(height: 6),

                    // Precio
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),

                    SizedBox(height: 6),

                    // Categoría y stock
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
                            SizedBox(width: 2),
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
                        // En lib/features/product/presentation/widgets/product_card.dart
// Después del Row que tiene categoría y stock, añade:

                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            // Convertir ProductModel a CartItem y añadir al carrito
                            final cartItem = CartItem(
                              id: product.id,
                              name: product.name,
                              price: product.price,
                              quantity: 1,
                              imageUrl: product.image?.url ?? '',
                              description: product.description,
                            );

                            // Añadir al carrito usando BLoC
                            context.read<CartBloc>().add(AddToCart(cartItem));

                            // Feedback visual
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    '✅ ${product.name} añadido al carrito'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            minimumSize: Size(double.infinity, 36),
                            padding: EdgeInsets.symmetric(horizontal: 12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_shopping_cart, size: 18),
                              SizedBox(width: 6),
                              Text('Añadir al carrito'),
                            ],
                          ),
                        ),
                      ],
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
