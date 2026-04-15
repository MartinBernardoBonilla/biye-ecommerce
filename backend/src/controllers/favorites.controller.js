import Favorite from '../models/favorite.js';
import Product from '../models/product.model.js';

// Obtener todos los favoritos del usuario
export const getFavorites = async (req, res) => {
  try {
    const userId = req.user.id;
    const favorites = await Favorite.getUserFavorites(userId);
    
    res.json({
      success: true,
      count: favorites.length,
      favorites: favorites
    });
  } catch (error) {
    console.error('Error getting favorites:', error);
    res.status(500).json({
      success: false,
      message: 'Error al obtener favoritos',
      error: error.message
    });
  }
};

// Agregar producto a favoritos
export const addFavorite = async (req, res) => {
  try {
    const userId = req.user.id;
    const { productId } = req.body;
    
    if (!productId) {
      return res.status(400).json({
        success: false,
        message: 'Se requiere productId'
      });
    }
    
    // Verificar que el producto existe
    const product = await Product.findById(productId);
    if (!product) {
      return res.status(404).json({
        success: false,
        message: 'Producto no encontrado'
      });
    }
    
    const favorite = await Favorite.addFavorite(userId, productId);
    
    if (!favorite) {
      return res.status(400).json({
        success: false,
        message: 'El producto ya está en favoritos'
      });
    }
    
    res.json({
      success: true,
      message: 'Producto agregado a favoritos',
      favorite: favorite
    });
  } catch (error) {
    console.error('Error adding favorite:', error);
    res.status(500).json({
      success: false,
      message: 'Error al agregar favorito',
      error: error.message
    });
  }
};

// Eliminar producto de favoritos
export const removeFavorite = async (req, res) => {
  try {
    const userId = req.user.id;
    const { productId } = req.params;
    
    const removed = await Favorite.removeFavorite(userId, productId);
    
    if (!removed) {
      return res.status(404).json({
        success: false,
        message: 'Favorito no encontrado'
      });
    }
    
    res.json({
      success: true,
      message: 'Producto eliminado de favoritos'
    });
  } catch (error) {
    console.error('Error removing favorite:', error);
    res.status(500).json({
      success: false,
      message: 'Error al eliminar favorito',
      error: error.message
    });
  }
};

// Verificar si un producto está en favoritos
export const checkFavorite = async (req, res) => {
  try {
    const userId = req.user.id;
    const { productId } = req.params;
    
    const isFavorite = await Favorite.isFavorite(userId, productId);
    
    res.json({
      success: true,
      isFavorite
    });
  } catch (error) {
    console.error('Error checking favorite:', error);
    res.status(500).json({
      success: false,
      message: 'Error al verificar favorito',
      error: error.message
    });
  }
};
