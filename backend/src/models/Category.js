// src/models/Category.js
// Define el esquema y el modelo para las categorías de productos (ES Modules)
import mongoose from 'mongoose';

const CategorySchema = new mongoose.Schema({
    name: {
        type: String,
        required: [true, 'El nombre de la categoría es obligatorio'],
        trim: true,
        unique: true,
        maxlength: [50, 'El nombre no puede tener más de 50 caracteres']
    },
    description: {
        type: String,
        required: false,
        maxlength: [200, 'La descripción no puede tener más de 200 caracteres']
    },
    image: {
        type: String, // URL de la imagen de la categoría
        required: false
    },
    createdAt: {
        type: Date,
        default: Date.now
    }
});

const Category = mongoose.model('Category', CategorySchema);
export default Category;