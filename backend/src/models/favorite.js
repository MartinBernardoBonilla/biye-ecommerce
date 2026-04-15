import mongoose from 'mongoose';

const favoriteSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  product: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Product',
    required: true
  },
  addedAt: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

// Índice compuesto único para evitar duplicados
favoriteSchema.index({ user: 1, product: 1 }, { unique: true });

// Método estático para obtener favoritos del usuario con datos del producto
favoriteSchema.statics.getUserFavorites = async function(userId) {
  const favorites = await this.find({ user: userId })
    .populate('product')
    .sort({ addedAt: -1 });
  
  // Formatear la respuesta para el frontend
  return favorites.map(fav => ({
    productId: fav.product._id,
    productName: fav.product.name,
    productPrice: fav.product.price,
    productImage: fav.product.image?.url || '',
    addedAt: fav.addedAt
  }));
};

// Método estático para verificar si un producto está en favoritos
favoriteSchema.statics.isFavorite = async function(userId, productId) {
  const favorite = await this.findOne({ user: userId, product: productId });
  return !!favorite;
};

// Método estático para agregar favorito
favoriteSchema.statics.addFavorite = async function(userId, productId) {
  try {
    const favorite = new this({
      user: userId,
      product: productId
    });
    await favorite.save();
    
    // Populate para obtener datos del producto
    await favorite.populate('product');
    
    return {
      productId: favorite.product._id,
      productName: favorite.product.name,
      productPrice: favorite.product.price,
      productImage: favorite.product.image?.url || '',
      addedAt: favorite.addedAt
    };
  } catch (error) {
    if (error.code === 11000) {
      // Ya existe en favoritos
      return null;
    }
    throw error;
  }
};

// Método estático para eliminar favorito
favoriteSchema.statics.removeFavorite = async function(userId, productId) {
  const result = await this.deleteOne({ user: userId, product: productId });
  return result.deletedCount > 0;
};

const Favorite = mongoose.model('Favorite', favoriteSchema);
export default Favorite;
