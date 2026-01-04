// src/models/Coupon.js
import mongoose from 'mongoose';

const CouponSchema = new mongoose.Schema({
    code: {
        type: String,
        required: [true, 'El código del cupón es obligatorio'],
        unique: true,
        uppercase: true,
    },
    discountType: {
        type: String,
        required: [true, 'El tipo de descuento es obligatorio'],
        enum: ['percent', 'fixed'],
    },
    discountValue: {
        type: Number,
        required: [true, 'El valor del descuento es obligatorio'],
    },
    expiresAt: {
        type: Date,
        required: [true, 'La fecha de vencimiento es obligatoria'],
    },
}, {
    timestamps: true,
});

const Coupon = mongoose.model('Coupon', CouponSchema);

export default Coupon;
