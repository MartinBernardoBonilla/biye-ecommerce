// src/controllers/coupons.controller.js
import asyncHandler from '../middleware/asyncHandler.middleware.js';
import Coupon from '../models/coupon.js';

// GET /api/v1/coupons
export const getCoupons = asyncHandler(async (req, res) => {
    const coupons = await Coupon.find().sort({ createdAt: -1 });
    res.status(200).json(coupons);
});

// POST /api/v1/coupons
export const createCoupon = asyncHandler(async (req, res) => {
    const coupon = await Coupon.create(req.body);
    res.status(201).json(coupon);
});

// DELETE /api/v1/coupons/:id
export const deleteCoupon = asyncHandler(async (req, res) => {
    const coupon = await Coupon.findById(req.params.id);

    if (!coupon) {
        res.status(404);
        throw new Error('Cupón no encontrado');
    }

    await coupon.deleteOne();
    res.status(200).json({ message: 'Cupón eliminado' });
});
