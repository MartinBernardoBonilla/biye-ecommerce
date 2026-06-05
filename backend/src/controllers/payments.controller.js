import mongoose from 'mongoose';
import asyncHandler from '../middleware/asyncHandler.middleware.js';
import * as PaymentService from '../services/payment.service.js';

export const createMercadoPagoPreference = asyncHandler(async (req, res) => {
  const { orderId } = req.params;

  if (!mongoose.Types.ObjectId.isValid(orderId)) {
    return res.status(400).json({ success: false, message: 'Order ID inválido' });
  }

  const result = await PaymentService.createLinkPayment(orderId);

  res.status(200).json({
    success: true,
    ...result,
  });
});

export const mercadoPagoWebhook = asyncHandler(async (req, res) => {
  await PaymentService.processWebhook(req, res);
});

export const createMercadoPagoQR = asyncHandler(async (req, res) => {
  const { orderId } = req.params;

  if (!mongoose.Types.ObjectId.isValid(orderId)) {
    return res.status(400).json({ success: false, message: 'Order ID inválido' });
  }

  const result = await PaymentService.createQRPayment(orderId);

  res.status(200).json(result);
});

export const checkPaymentStatus = asyncHandler(async (req, res) => {
  const { orderId } = req.params;

  if (!mongoose.Types.ObjectId.isValid(orderId)) {
    return res.status(400).json({ success: false, message: 'ID inválido' });
  }

  // ✅ LE SACAMOS EL BYPASS: Ahora consulta el estado verdadero de la base de datos
  const result = await PaymentService.checkPaymentStatus(orderId);

  res.status(200).json({
    success: true,
    ...result, // Esto va a retornar el { status: 'PENDING' | 'PAID' | 'approved' } real
  });
});

// ✅ FIX 2: Endpoint para actualizar estado manualmente (fallback)
export const updatePaymentStatus = asyncHandler(async (req, res) => {
  const { orderId, status } = req.body;

  if (!mongoose.Types.ObjectId.isValid(orderId)) {
    return res.status(400).json({ success: false, message: 'ID inválido' });
  }

  if (!status || !['pending', 'approved', 'rejected'].includes(status)) {
    return res.status(400).json({ success: false, message: 'Status inválido' });
  }

  const result = await PaymentService.updatePaymentStatus(orderId, status);

  res.status(200).json({
    success: true,
    ...result,
  });
});