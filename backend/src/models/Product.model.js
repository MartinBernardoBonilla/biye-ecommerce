// src/models/Product.model.js

import mongoose from 'mongoose';

const productSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      required: true,
      ref: 'User',
    },

    name: {
      type: String,
      required: [true, 'El nombre del producto es obligatorio'],
      trim: true,
      unique: true,
      maxlength: [120, 'El nombre no puede superar los 120 caracteres'],
    },

    description: {
      type: String,
      required: [true, 'La descripción es obligatoria'],
      maxlength: [2000, 'La descripción es demasiado larga'],
    },

    price: {
      type: Number,
      required: [true, 'El precio es obligatorio'],
      min: [0, 'El precio no puede ser negativo'],
      default: 0,
    },

    countInStock: {
      type: Number,
      required: [true, 'El stock es obligatorio'],
      min: [0, 'El stock no puede ser negativo'],
      default: 0,
    },

    category: {
      type: String,
      required: [true, 'La categoría es obligatoria'],
      index: true,
    },

    image: {
      url: {
        type: String,
      },
      public_id: {
        type: String,
      },
    },

    isActive: {
      type: Boolean,
      default: true,
      index: true,
    },

    featured: {
      type: Boolean,
      default: false,
    },


  },
  {
    timestamps: true,
  }
);

// 🔍 Índices compuestos (opcional pero recomendado)
productSchema.index({ createdAt: -1 });

const Product = mongoose.model('Product', productSchema);

export default Product;
