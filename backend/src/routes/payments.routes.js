import { Router } from 'express';
import {
  createMercadoPagoPreference,
  mercadoPagoWebhook,
} from '../controllers/payments.controller.js';
import { protect } from '../middleware/auth.middleware.js';

const router = Router();

// ✅ 1. WEBHOOK PRIMERO (SIN AUTH)
router.post('/mercadopago/webhook', mercadoPagoWebhook);

// ✅ 2. RUTA CON PARAM DESPUÉS
router.post('/mercadopago/:orderId', protect, createMercadoPagoPreference);

export default router;
