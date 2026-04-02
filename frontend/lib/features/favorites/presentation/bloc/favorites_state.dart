import 'package:equatable/equatable.dart';
import '../../domain/entities/favorite_item.dart';

abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

// Estado inicial
class FavoritesInitial extends FavoritesState {}

// Estado de carga
class FavoritesLoading extends FavoritesState {}

// Estado con lista de favoritos
class FavoritesLoaded extends FavoritesState {
  final List<FavoriteItem> favorites;

  const FavoritesLoaded({required this.favorites});

  @override
  List<Object?> get props => [favorites];
}

// Estado para saber si un producto es favorito
class FavoriteStatus extends FavoritesState {
  final String productId;
  final bool isFavorite;

  const FavoriteStatus({
    required this.productId,
    required this.isFavorite,
  });

  @override
  List<Object?> get props => [productId, isFavorite];
}

// Estado de error
class FavoritesError extends FavoritesState {
  final String message;

  const FavoritesError({required this.message});

  @override
  List<Object?> get props => [message];
}
