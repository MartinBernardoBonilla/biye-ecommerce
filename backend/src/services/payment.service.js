import { MercadoPagoConfig, Preference, Payment } from 'mercadopago';
import Order from '../models/order.js';
import QRCode from 'qrcode';

const client = new MercadoPagoConfig({
  accessToken: process.env.MERCADOPAGO_ACCESS_TOKEN,
});

// ✅ Set para idempotencia (en producción usa Redis)
const processedPayments = new Set();

// Limpiar payments procesados cada hora para evitar crecimiento infinito
setInterval(() => {
  console.log(`🧹 Limpiando cache de webhooks. Tamaño actual: ${processedPayments.size}`);
  processedPayments.clear();
}, 60 * 60 * 1000);

// =======================
// CREATE QR PAYMENT
// =======================
export const createQRPayment = async (orderId) => {
  try {
    const order = await Order.findById(orderId);
    if (!order) throw new Error('Orden no encontrada');

    const orderIdString = String(order._id);

    console.log('🧪 Enviando a MP orderId:', orderIdString);

    const preference = new Preference(client);

    const response = await preference.create({
      body: {
        items: order.items.map(item => ({
          title: item.name,
          quantity: Number(item.quantity),
          unit_price: Number(item.unitPrice || item.price || 0),
          currency_id: 'ARS',
        })),
        notification_url: `${process.env.BACK_URL}/api/v1/payments/webhook`,
        external_reference: orderIdString,
        metadata: {
          order_id: orderIdString,
        },
        binary_mode: true,
      }
    });

    console.log('✅ Preference creada. ID:', response.id);

    // ✅ Generar QR como imagen base64
    const qrCodeBase64 = await QRCode.toDataURL(response.init_point);
    const qrImageBase64 = qrCodeBase64.replace(/^data:image\/png;base64,/, '');

    return {
      success: true,
      qrData: response.init_point,
      qrImageBase64: qrImageBase64,
      orderId: order._id,
    };
  } catch (error) {
    console.error('❌ Error en createQRPayment:', error.message);
    return { success: false, message: error.message };
  }
};

// =======================
// CHECK PAYMENT STATUS
// =======================
export const checkPaymentStatus = async (orderId) => {
  const order = await Order.findById(orderId);
  if (!order) throw new Error('Orden no encontrada');

  return {
    status: order.paymentStatus || 'pending',
    orderId: order._id,
    isPaid: order.isPaid
  };
};

// =======================
// WEBHOOK CON IDEMPOTENCIA
// =======================
export const processWebhook = async (req, res) => {
  try {
    console.log('🪝 Webhook recibido body:', JSON.stringify(req.body, null, 2));
    console.log('🪝 Webhook recibido query:', req.query);

    // ✅ Extraer paymentId de diferentes formatos de MP
    const paymentId = req.body.data?.id ||
      req.body.id ||
      req.query.id ||
      req.query['data.id'] ||
      null;

    if (!paymentId) {
      console.log('❌ No se encontró paymentId');
      return res.sendStatus(200);
    }

    console.log('📦 paymentId extraído:', paymentId);

    // ✅ IDEMPOTENCIA: Evitar procesar el mismo pago dos veces
    if (processedPayments.has(paymentId)) {
      console.log(`⏩ Webhook duplicado ignorado: ${paymentId}`);
      return res.sendStatus(200);
    }

    // Marcar como procesado
    processedPayments.add(paymentId);
    console.log(`🪝 Procesando webhook por primera vez: ${paymentId}`);

    const paymentClient = new Payment(client);
    const payment = await paymentClient.get({ id: String(paymentId) });

    console.log('💰 Payment status:', payment.status);
    console.log('💰 external_reference:', payment.external_reference);

    const orderId = payment.external_reference || payment.metadata?.order_id;

    if (!orderId) {
      console.log('❌ No se pudo obtener orderId');
      return res.sendStatus(200);
    }

    const order = await Order.findById(orderId);
    if (!order) {
      console.log('❌ Orden no encontrada:', orderId);
      return res.sendStatus(200);
    }

    // ✅ Solo actualizar si no estaba ya aprobado
    if (order.paymentStatus === 'approved') {
      console.log(`⏩ Orden ${orderId} ya estaba aprobada. Ignorando.`);
      return res.sendStatus(200);
    }

    order.paymentStatus = payment.status;
    order.isPaid = payment.status === 'approved';
    if (order.isPaid) order.status = 'PAID';

    await order.save();
    console.log(`✅ Orden ${orderId} actualizada. Status: ${order.paymentStatus}`);

    res.sendStatus(200);
  } catch (error) {
    console.error('❌ Error en webhook:', error);
    res.sendStatus(200); // Siempre responder 200 a MP
  }
};

// =======================
// UPDATE PAYMENT STATUS (FALLBACK)
// =======================
export const updatePaymentStatus = async (orderId, status) => {
  const order = await Order.findById(orderId);
  if (!order) throw new Error('Orden no encontrada');

  order.paymentStatus = status;
  order.isPaid = status === 'approved';
  if (order.isPaid) order.status = 'PAID';

  await order.save();
  console.log(`✅ Orden ${orderId} actualizada manualmente. Status: ${status}`);

  return { success: true, orderId: order._id };
};