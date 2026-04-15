import mongoose from 'mongoose';

// Constante para la imagen por defecto (fácil de cambiar después)
const DEFAULT_PRODUCT_IMAGE = 'https://res.cloudinary.com/dwchpxcrv/image/upload/default-product_zbscxc.png';
const DEFAULT_PUBLIC_ID = 'default-product_zbscxc'; // 👈 CORREGIDO

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
        // 👇 CORREGIDO: sin punto y coma al final
        default: DEFAULT_PRODUCT_IMAGE,
      },
      public_id: {
        type: String,
        // 👇 CORREGIDO: debe ser el public_id, no la URL completa
        default: DEFAULT_PUBLIC_ID,
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

// 🔍 Índices compuestos
productSchema.index({ createdAt: -1 });

// 👇 MIDDLEWARE PARA GARANTIZAR IMAGEN POR DEFECTO AL GUARDAR
productSchema.pre('save', function(next) {
  // Si no hay imagen o la URL está vacía, asignar la default
  if (!this.image || !this.image.url) {
    this.image = {
      url: DEFAULT_PRODUCT_IMAGE,
      public_id: DEFAULT_PUBLIC_ID, // 👈 CORREGIDO: usa la constante
    };
  }
  next();
});

// 👇 MIDDLEWARE PARA ACTUALIZACIONES
productSchema.pre('findOneAndUpdate', function(next) {
  const update = this.getUpdate();
  
  // Si están actualizando y no incluyen image, no hacer nada
  // Si incluyen image pero está vacía, poner la default
  if (update.image && !update.image.url) {
    update.image.url = DEFAULT_PRODUCT_IMAGE;
    update.image.public_id = DEFAULT_PUBLIC_ID; // 👈 CORREGIDO
  }
  
  next();
});

const Product = mongoose.model('Product', productSchema);

export default Product;