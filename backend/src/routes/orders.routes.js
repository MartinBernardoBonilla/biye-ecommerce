// src/routes/orders.routes.js
import { Router } from 'express';

import {
    createOrder,
    getMyOrders,
    getOrderById,
    updateOrderToPaid,
} from '../controllers/orders.controller.js';

import { protect, admin } from '../middleware/auth.middleware.js';

const router = Router();

// Usuario autenticado
router.post('/', protect, createOrder);
router.get('/myorders', protect, getMyOrders);
router.get('/:id', protect, getOrderById);

// Admin / pagos
router.put('/:id/pay', protect, updateOrderToPaid);

export default router;
