import express from 'express';
import { protect } from '../middleware/auth.middleware.js';
import {
  createMercadoPagoPreference,
  mercadoPagoWebhook,
  createMercadoPagoQR,
  checkPaymentStatus,
  updatePaymentStatus, // ✅ NUEVO
} from '../controllers/payments.controller.js';

const router = express.Router();

router.post('/mercadopago/:orderId', protect, createMercadoPagoPreference);
router.post('/webhook', mercadoPagoWebhook);
router.post('/qr/:orderId', protect, createMercadoPagoQR);
router.get('/status/:orderId', protect, checkPaymentStatus);
router.post('/update-status', protect, updatePaymentStatus); // ✅ NUEVO (fallback)

export default router;