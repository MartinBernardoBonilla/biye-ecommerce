import { Router } from 'express';
// Importamos las funciones del controlador
import { createOrder, handleMercadoPagoWebhook } from '../controllers/payments.controller.js'; 

const router = Router();

/**
 * POST /api/v1/payments/create-order
 * Ruta para generar la preferencia de pago (Paso 1). 
 * Recibe el carrito y devuelve el ID de preferencia de Mercado Pago.
 */
router.post('/create-order', createOrder);

/**
 * POST /api/v1/payments/mercadopago-webhook
 * Ruta para recibir notificaciones (IPN) de Mercado Pago (Paso 2).
 * Esta URL DEBE ser pública (usando ngrok o un dominio real) y es llamada por MP.
 */
router.post('/mercadopago-webhook', handleMercadoPagoWebhook); 

export default router;
