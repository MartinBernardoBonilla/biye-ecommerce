import mongoose from 'mongoose';
import { Preference, Payment } from 'mercadopago';
import mpClient from '../config/mercadopago.js';
import Order from '../models/Order.js';
import asyncHandler from '../middleware/asyncHandler.middleware.js';
import { updateProductStock } from '../services/inventory.service.js';

/**
 * Crear preferencia de Mercado Pago (Checkout Pro)
 */
export const createMercadoPagoPreference = asyncHandler(async (req, res) => {
  const { orderId } = req.params;

  if (!mongoose.Types.ObjectId.isValid(orderId)) {
    return res.status(400).json({ success: false, message: 'Order ID inválido' });
  }

  const order = await Order.findById(orderId);
  if (!order) {
    return res.status(404).json({ success: false, message: 'Orden no encontrada' });
  }

  const preference = new Preference(mpClient);

  const body = {
    items: order.items.map((item) => ({
      title: item.name,
      quantity: item.quantity,
      unit_price: Number(item.unitPrice),
      currency_id: 'ARS',
    })),
    external_reference: order._id.toString(),
    back_urls: {
      success: `${process.env.FRONTEND_URL}/checkout/success`,
      failure: `${process.env.FRONTEND_URL}/checkout/failure`,
      pending: `${process.env.FRONTEND_URL}/checkout/pending`,
    },
    binary_mode: true,
    notification_url: `${process.env.NGROK_BASE_URL}/api/v1/payments/webhook`,
  };

  const result = await preference.create({ body });

  console.log('-----------------------------------------');
  console.log('🚀 ORDEN:', orderId);
  console.log('🔗 LINK PARA ENVIAR A TU AMIGO:', result.init_point);
  console.log('Preference ID:', result.id);
  console.log('Body enviado a MP:', JSON.stringify(body, null, 2));
  console.log('-----------------------------------------');

  order.paymentDetails = {
    method: 'mercadopago',
    preferenceId: result.id,
  };
  order.status = 'WAITING_PAYMENT';
  await order.save();

  const checkoutUrl = result.init_point;

  res.status(200).json({
    success: true,
    preferenceId: result.id,
    checkoutUrl,
  });
});

export const mercadoPagoWebhook = asyncHandler(async (req, res) => {
  // 1. Logs iniciales para debug
  console.log('🔔 Webhook MP - Hora:', new Date().toISOString());
  console.log('🔥 WEBHOOK REAL DISPARADO');
  console.log('📦 BODY:', JSON.stringify(req.body, null, 2));
  console.log('📦 HEADERS:', req.headers);

  // 2. Extraer paymentId y filtrar por tipo
  const paymentId = req.body?.data?.id || req.body?.id || req.query?.id;
  const topic = req.body?.type || req.query?.topic;

  // Solo procesamos pagos (no planes, suscripciones, etc.)
  if (!paymentId || (topic && topic !== 'payment')) {
    console.log('⏭️ No es un pago o no hay ID, respondiendo 200');
    return res.sendStatus(200);
  }

  console.log('💳 Payment ID:', paymentId);

  try {
    // 3. Consultar pago en MP
    const payment = new Payment(mpClient);
    const info = await payment.get({ id: paymentId });

    const orderId = info.external_reference;
    console.log('🔗 External reference (orderId):', orderId);

    if (!mongoose.Types.ObjectId.isValid(orderId)) {
      console.log('❌ Order ID inválido');
      return res.sendStatus(200);
    }

    const order = await Order.findById(orderId);
    if (!order) {
      console.log('❌ Orden no encontrada');
      return res.sendStatus(200);
    }

    console.log('📦 Orden encontrada, status actual:', order.status);

    // 4. 🚩 GUARDA DE IDEMPOTENCIA (clave para no duplicar)
    if (order.status === 'PAID') {
      console.log(`♻️ Orden ${orderId} ya estaba PAID. Ignorando webhook duplicado.`);
      return res.sendStatus(200);
    }

    const status = (info.status || '').toLowerCase();
    console.log('📊 Status MP:', status);

    // 5. Actualizar datos en memoria (aún no guardamos)
    order.paymentDetails = {
      ...order.paymentDetails,
      paymentId: info.id,
      statusDetail: status,
      method: order.paymentDetails?.method || 'mercadopago',
      updatedByWebhook: new Date(),
    };

    // 6. Procesar según status
    if (status === 'approved') {
      console.log('💰 Pago aprobado! Actualizando orden...');
      order.status = 'PAID';
      order.paidAt = new Date();

      // Descontar stock (con manejo de error independiente)
      try {
        await updateProductStock(orderId, {
          id: info.id,
          status: info.status,
          email_payer: info.payer?.email || 'desconocido',
        });
        console.log('✅ Stock actualizado');
      } catch (stockError) {
        // Logeamos pero no frenamos el proceso
        console.error('⚠️ Error actualizando stock:', stockError.message);
      }

    } else if (status === 'rejected') {
      console.log('❌ Pago rechazado');
      order.status = 'PAYMENT_REJECTED';
    } else if (status === 'cancelled') {
      console.log('🚫 Pago cancelado');
      order.status = 'CANCELLED';
    } else if (status === 'refunded') {
      console.log('↩️ Pago reembolsado');
      order.status = 'REFUNDED';
    } else {
      console.log(`⏳ Estado no definitivo: ${status}`);
      order.status = 'WAITING_PAYMENT';
    }

    // 7. GUARDADO ÚNICO (después de todas las modificaciones)
    await order.save();
    console.log(`✅ Orden ${orderId} guardada con status: ${order.status}`);

  } catch (error) {
    console.error('❌ ERROR CRÍTICO EN WEBHOOK:', error);
    // Devolvemos 500 para que MP reintente
    return res.status(500).json({ error: 'Webhook processing failed' });
  }

  // 8. Siempre responder 200 a MP
  res.sendStatus(200);
});


/**
 * 🆕 Crear QR REAL de Mercado Pago
 */
/**
 * Crear QR de Mercado Pago usando Preference REAL
 */
export const createMercadoPagoQR = asyncHandler(async (req, res) => {
  const { orderId } = req.params;

  if (!mongoose.Types.ObjectId.isValid(orderId)) {
    return res.status(400).json({ success: false, message: 'Order ID inválido' });
  }

  const order = await Order.findById(orderId);
  if (!order) {
    return res.status(404).json({ success: false, message: 'Orden no encontrada' });
  }

  console.log('📱 Generando QR REAL para Orden:', orderId);

  // Usar el mismo Preference que ya funciona para checkout web
  const preference = new Preference(mpClient);

  const body = {
    items: order.items.map((item) => ({
      title: item.name,
      quantity: Number(item.quantity),
      unit_price: Number(item.unitPrice),
      currency_id: 'ARS',
    })),
    external_reference: order._id.toString(),
    notification_url: `${process.env.NGROK_BASE_URL}/api/v1/payments/webhook`,
    binary_mode: true,
    // Expira en 10 minutos
    expiration_date_from: new Date().toISOString(),
    expiration_date_to: new Date(Date.now() + 10 * 60 * 1000).toISOString(),
  };

  const result = await preference.create({ body });

  console.log('✅ Preference REAL creada:', result.id);
  console.log('🔗 init_point QR:', result.init_point);

  // Guardar preferenceId REAL
  order.paymentDetails = {
    method: 'qr',
    preferenceId: result.id,
    statusDetail: 'waiting_scan',
  };
  order.status = 'WAITING_PAYMENT';
  await order.save();

  res.status(200).json({
    success: true,
    qrData: result.init_point,   // 👈 ESTO es lo que va al QR
    orderId: order._id,
    preferenceId: result.id,
    expiresAt: new Date(Date.now() + 10 * 60 * 1000).toISOString(),
  });
});
/**
 * 🆕 Verificar estado del pago consultando a Mercado Pago
 */
/**
 * 🆕 Verificar estado del pago (Polling robusto)
 */
export const checkPaymentStatus = asyncHandler(async (req, res) => {
  const { orderId } = req.params;
  console.log("RECIBIDO EN BACKEND: ", req.params.orderId);
  // Log para ver qué llega desde Flutter
  console.log(`🔍 Polling: Verificando orden ${orderId}`);

  if (!mongoose.Types.ObjectId.isValid(orderId)) {
    return res.status(400).json({ success: false, message: 'ID de orden no válido' });
  }

  const order = await Order.findById(orderId);
  
  if (!order) {
    console.log('❌ Orden no encontrada en DB');
    return res.status(404).json({ success: false, message: 'Orden no encontrada' });
  }

  // 1. Si la orden YA está pagada en nuestra DB, no le preguntamos a MP
  if (order.status === 'PAID') {
    return res.status(200).json({
      success: true,
      status: 'approved',
      orderId: order._id
    });
  }

  const paymentId = order.paymentDetails?.paymentId;

  // 2. Si no hay paymentId o es un mock (empieza con PAY-), devolvemos el estado de la DB
  // Esto evita que el SDK de MP explote intentando buscar un ID que no existe
  if (!paymentId || paymentId.startsWith('PAY-')) {
    console.log('⏳ Sin pago real aún (esperando scan)...');
    return res.status(200).json({
      success: true,
      status: order.status === 'WAITING_PAYMENT' ? 'pending' : order.status.toLowerCase(),
      orderId: order._id
    });
  }

  try {
    const payment = new Payment(mpClient);
    const paymentInfo = await payment.get({ id: paymentId });
    const mpStatus = (paymentInfo.status || '').toLowerCase();

    console.log(`📊 MP dice para ${paymentId}: ${mpStatus}`);

    if (mpStatus === 'approved') {
      order.status = 'PAID';
      order.paidAt = new Date();
      order.paymentDetails.statusDetail = 'approved';
      
      await order.save();
      
      try {
        await updateProductStock(orderId, {
          id: paymentInfo.id,
          status: paymentInfo.status,
          email_payer: paymentInfo.payer?.email || 'desconocido',
        });
      } catch (invError) {
        console.error('⚠️ Error stock:', invError.message);
      }
    }

    return res.status(200).json({
      success: true,
      status: mpStatus,
      orderId: order._id
    });

  } catch (error) {
    // Si MP falla (404, 401, etc.), no rompemos el polling, devolvemos lo que tenemos en DB
    console.error('⚠️ Error SDK MP:', error.message);
    return res.status(200).json({
      success: true,
      status: order.status.toLowerCase() === 'waiting_payment' ? 'pending' : 'error',
      orderId: order._id,
      error: 'MP_FETCH_ERROR'
    });
  }
});









