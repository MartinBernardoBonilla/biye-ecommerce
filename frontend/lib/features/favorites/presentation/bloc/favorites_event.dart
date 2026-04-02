import 'package:equatable/equatable.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

// Cargar favoritos al iniciar
class LoadFavorites extends FavoritesEvent {}

// Agregar producto a favoritos
class AddFavorite extends FavoritesEvent {
  final String productId;
  final String productName;
  final double productPrice;
  final String productImage;

  const AddFavorite({
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.productImage,
  });

  @override
  List<Object?> get props =>
      [productId, productName, productPrice, productImage];
}

// Quitar producto de favoritos
class RemoveFavorite extends FavoritesEvent {
  final String productId;

  const RemoveFavorite({required this.productId});

  @override
  List<Object?> get props => [productId];
}

// Verificar si un producto está en favoritos
class CheckIsFavorite extends FavoritesEvent {
  final String productId;

  const CheckIsFavorite({required this.productId});

  @override
  List<Object?> get props => [productId];
}
