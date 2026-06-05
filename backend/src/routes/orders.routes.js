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

// 👤 Rutas de Usuario Autenticado
router.post('/', protect, createOrder); // 💡 Consejo: Meté 'protect' acá para asegurar que req.user exista al crear la orden
router.get('/myorders', protect, getMyOrders);
router.get('/:id', protect, getOrderById);
router.get('/:id/status', protect, getOrderStatus);

// 💳 Pasarela de Pagos / Simulación
// Sacamos 'admin' temporalmente para poder probar el flujo con tu usuario común
router.put('/:id/pay', updateOrderToPaid);

export default router;