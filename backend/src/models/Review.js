// src/models/Review.js
// Define el esquema y el modelo para las reseñas de productos.
import mongoose from 'mongoose';

const ReviewSchema = new mongoose.Schema({
    user: {
        type: mongoose.Schema.Types.ObjectId,
        required: true,
        ref: 'User' // Referencia al modelo de usuario
    },
    product: {
        type: mongoose.Schema.Types.ObjectId,
        required: true,
        ref: 'Product' // Referencia al modelo de producto
    },
    rating: {
        type: Number,
        required: true,
        min: 1,
        max: 5
    },
    comment: {
        type: String,
        required: true
    }
}, {
    timestamps: true // Agrega campos de fecha de creación y actualización
});

export default mongoose.model('Review', ReviewSchema);
