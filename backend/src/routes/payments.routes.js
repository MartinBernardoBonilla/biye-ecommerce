import express from 'express';
import { 
  createMercadoPagoPreference,
  mercadoPagoWebhook,
  createMercadoPagoQR,
  checkPaymentStatus,
} from '../controllers/payments.controller.js';
import { protect } from '../middleware/auth.middleware.js';

const router = express.Router();

// ✅ PÚBLICAS (sin protect)
router.post('/webhook', mercadoPagoWebhook);
router.post('/mercadopago/qr/:orderId', createMercadoPagoQR);
router.get('/status/:orderId', checkPaymentStatus);

// ✅ PROTEGIDAS (con protect)
router.post('/mercadopago/:orderId', protect, createMercadoPagoPreference);
export default router;
