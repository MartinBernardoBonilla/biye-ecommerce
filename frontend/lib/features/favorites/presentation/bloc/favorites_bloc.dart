import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../domain/entities/favorite_item.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoritesRepository repository;

  FavoritesBloc({required this.repository}) : super(FavoritesInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<AddFavorite>(_onAddFavorite);
    on<RemoveFavorite>(_onRemoveFavorite);
    on<CheckIsFavorite>(_onCheckIsFavorite);
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(FavoritesLoading());
    try {
      final favorites = await repository.getFavorites();
      print('📚 [BLOC] Favoritos cargados: ${favorites.length}');
      emit(FavoritesLoaded(favorites: favorites));
    } catch (e) {
      print('❌ [BLOC] Error cargando favoritos: $e');
      emit(FavoritesError(message: 'Error cargando favoritos: $e'));
    }
  }

  Future<void> _onAddFavorite(
    AddFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final newItem = FavoriteItem.fromProduct(
        productId: event.productId,
        productName: event.productName,
        productPrice: event.productPrice,
        productImage: event.productImage,
      );

      final success = await repository.addFavorite(newItem);

      if (success) {
        // ✅ 1. Recargar lista completa
        final favorites = await repository.getFavorites();
        print('➕ [BLOC] Favorito agregado. Total: ${favorites.length}');

        // ✅ 2. Emitir FavoritesLoaded (para actualizar página de favoritos)
        emit(FavoritesLoaded(favorites: favorites));

        // ✅ 3. Emitir FavoriteStatus (para actualizar corazones)
        emit(FavoriteStatus(
          productId: event.productId,
          isFavorite: true,
        ));
      }
    } catch (e) {
      print('❌ [BLOC] Error agregando favorito: $e');
      emit(FavoritesError(message: 'Error agregando a favoritos: $e'));
    }
  }

  Future<void> _onRemoveFavorite(
    RemoveFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final success = await repository.removeFavorite(event.productId);

      if (success) {
        // ✅ 1. Recargar lista completa
        final favorites = await repository.getFavorites();
        print('➖ [BLOC] Favorito eliminado. Total: ${favorites.length}');

        // ✅ 2. Emitir FavoritesLoaded (para actualizar página de favoritos)
        emit(FavoritesLoaded(favorites: favorites));

        // ✅ 3. Emitir FavoriteStatus (para actualizar corazones)
        emit(FavoriteStatus(
          productId: event.productId,
          isFavorite: false,
        ));
      }
    } catch (e) {
      print('❌ [BLOC] Error eliminando favorito: $e');
      emit(FavoritesError(message: 'Error eliminando de favoritos: $e'));
    }
  }

  Future<void> _onCheckIsFavorite(
    CheckIsFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final isFavorite = await repository.isFavorite(event.productId);
      emit(FavoriteStatus(
        productId: event.productId,
        isFavorite: isFavorite,
      ));
    } catch (e) {
      print('❌ [BLOC] Error verificando favorito: $e');
      emit(FavoritesError(message: 'Error verificando favorito: $e'));
    }
  }
}
