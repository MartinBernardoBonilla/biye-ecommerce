import mongoose from 'mongoose';
import { Preference, Payment } from 'mercadopago';
import mpClient from '../config/mercadopago.js';
import Order from '../models/Order.js';
import asyncHandler from '../middleware/asyncHandler.middleware.js';

/**
 * Crear preferencia de Mercado Pago a partir de una orden
 */
export const createMercadoPagoPreference = asyncHandler(async (req, res) => {
  const { orderId } = req.params;

  // Validar ObjectId
  if (!mongoose.Types.ObjectId.isValid(orderId)) {
    return res.status(400).json({
      success: false,
      message: 'Order ID inválido',
    });
  }

  // Buscar orden
  const order = await Order.findById(orderId);
  if (!order) {
    return res.status(404).json({
      success: false,
      message: 'Orden no encontrada',
    });
  }

  // Crear preferencia
  const preference = new Preference(mpClient);

  const body = {
    items: order.items.map((item) => ({
      title: item.name,
      quantity: item.quantity,
      unit_price: item.unitPrice,
      currency_id: 'ARS',
    })),

    payer: {
      email: order.buyerInfo.email,
    },

    external_reference: order._id.toString(),

    back_urls: {
      success: `${process.env.FRONTEND_URL}/checkout/success`,
      failure: `${process.env.FRONTEND_URL}/checkout/failure`,
      pending: `${process.env.FRONTEND_URL}/checkout/pending`,
    },

    auto_return: 'approved',

    notification_url: `${process.env.NGROK_BASE_URL}/api/v1/payments/webhook`,
  };

const result = await preference.create({ body });

// Guardar info de pago en la orden
order.paymentDetails = {
  method: 'mercadopago',
  preferenceId: result.id,
};
order.status = 'WAITING_PAYMENT';
await order.save();

// 🔴 ESTE ES EL PUNTO CLAVE
const checkoutUrl =
  process.env.NODE_ENV === 'production'
    ? result.init_point
    : result.sandbox_init_point;

res.status(200).json({
  success: true,
  preferenceId: result.id,
  checkoutUrl,
});

});

/**
 * Webhook Mercado Pago
 */
export const mercadoPagoWebhook = asyncHandler(async (req, res) => {
  const paymentId =
    req.query.id ||
    req.body?.data?.id ||
    req.body?.resource;

  if (!paymentId) return res.sendStatus(200);

  const payment = new Payment(mpClient);
  const info = await payment.get({ id: paymentId });

  const orderId = info.body.external_reference;
  if (!mongoose.Types.ObjectId.isValid(orderId)) {
    return res.sendStatus(200);
  }

  const order = await Order.findById(orderId);
  if (!order) return res.sendStatus(200);

  const status = info.body.status;

  if (status === 'approved') {
    order.status = 'PAID';
    order.paidAt = new Date();
  } else if (status === 'rejected') {
    order.status = 'REJECTED';
  } else {
    order.status = 'WAITING_PAYMENT';
  }

  order.paymentDetails = {
    ...order.paymentDetails,
    paymentId: info.body.id,
    statusDetail: status,
  };

  await order.save();

  res.sendStatus(200);
});