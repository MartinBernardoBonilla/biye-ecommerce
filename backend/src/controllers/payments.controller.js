import mongoose from 'mongoose';
import { Preference, Payment } from 'mercadopago';
import mpClient from '../config/mercadopago.js';
import Order from '../models/Order.js';
import asyncHandler from '../middleware/asyncHandler.middleware.js';

/**
 * Crear preferencia MercadoPago desde una orden existente
 */
export const createMercadoPagoPreference = asyncHandler(async (req, res) => {
  const { orderId } = req.params;

  if (!mongoose.Types.ObjectId.isValid(orderId)) {
    return res.status(400).json({
      success: false,
      message: 'Order ID inválido',
    });
  }

  const order = await Order.findById(orderId);
  if (!order) {
    return res.status(404).json({
      success: false,
      message: 'Orden no encontrada',
    });
  }

  if (order.paymentDetails?.preferenceId) {
    return res.status(400).json({
      success: false,
      message: 'La orden ya tiene una preferencia creada',
    });
  }

  const preference = new Preference(mpClient);

  const body = {
    items: order.items.map(item => ({
      title: item.name,
      unit_price: item.unitPrice,
      quantity: item.quantity,
      currency_id: order.currency,
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
    notification_url: `${process.env.NGROK_BASE_URL}/api/v1/payments/mercadopago/webhook`,
  };

  const result = await preference.create({ body });

  order.paymentDetails = {
    preferenceId: result.id,
    method: 'mercadopago',
  };
  order.status = 'WAITING_PAYMENT';
  await order.save();

  res.json({
    success: true,
    preferenceId: result.id,
    initPoint: result.init_point,
  });
});

/**
 * Webhook MercadoPago
 */
export const mercadoPagoWebhook = asyncHandler(async (req, res) => {
  const paymentId =
    req.query.id ||
    req.body?.data?.id ||
    req.body?.resource;

  if (!paymentId) return res.sendStatus(200);

  const payment = new Payment(mpClient);
  const info = await payment.get({ id: paymentId });

  const orderId = info.external_reference;
  if (!mongoose.Types.ObjectId.isValid(orderId)) {
    return res.sendStatus(200);
  }

  const order = await Order.findById(orderId);
  if (!order) return res.sendStatus(200);

  if (info.status === 'approved') {
    order.status = 'PAID';
    order.paidAt = new Date();
  }

  order.paymentDetails = {
    ...order.paymentDetails,
    paymentId: info.id,
    statusDetail: info.status,
  };

  await order.save();
  res.sendStatus(200);
});
