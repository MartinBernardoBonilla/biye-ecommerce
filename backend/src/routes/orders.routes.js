// src/routes/orders.routes.js
import { Router } from 'express';

import {
    createOrder,
    getMyOrders,
    getOrderById,
    updateOrderToPaid,
    getOrderStatus,
} from '../controllers/order.controller.js';

import { protect, admin } from '../middleware/auth.middleware.js';

const router = Router();

// Usuario autenticado
router.post('/', createOrder);
router.get('/myorders', protect, getMyOrders);
router.get('/:id', protect, getOrderById);
router.get('/:id/status', protect, getOrderStatus);


// Admin / pagos
router.put('/:id/pay', protect, admin, updateOrderToPaid);

export default router;
