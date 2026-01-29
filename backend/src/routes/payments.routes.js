import { Router } from 'express';
import {
  createMercadoPagoPreference,
  mercadoPagoWebhook,
} from '../controllers/payments.controller.js';
import { protect } from '../middleware/auth.middleware.js';

const router = Router();

// ✅ 1. WEBHOOK PRIMERO (SIN AUTH)
// routes/payments.routes.js (o donde tengas payments)
router.post('/webhook', async (req, res) => {
  try {
    const { id, topic } = req.query;

    console.log('🔔 Webhook MP recibido');
    console.log('Topic:', topic);
    console.log('ID:', id);

    // RESPONDER SIEMPRE 200
    res.sendStatus(200);

    // Luego (async, opcional):
    // - consultar a MP el estado real del pago
    // - actualizar orden
    // - activar producto
  } catch (error) {
    console.error('❌ Error webhook MP:', error);
    res.sendStatus(200); // MUY IMPORTANTE
  }
});


// ✅ 2. RUTA CON PARAM DESPUÉS
router.post('/mercadopago/:orderId', createMercadoPagoPreference);

export default router;
