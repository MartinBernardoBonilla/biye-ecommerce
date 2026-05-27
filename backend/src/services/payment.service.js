import { MercadoPagoConfig, Preference, Payment } from 'mercadopago';
import Order from '../models/order.js';
import QRCode from 'qrcode';
// 🚚 IMPORTAMOS EL MANAGER DE LOGÍSTICA
import { processOrderLogistics } from '../services/shipping.manager.js';

const client = new MercadoPagoConfig({
  accessToken: process.env.MERCADOPAGO_ACCESS_TOKEN,
});

// ✅ Set para idempotencia (en producción usa Redis)
export const processedPayments = new Set();

// Limpiar payments procesados cada hora para evitar crecimiento infinito
export const webhookCacheInterval = setInterval(() => {
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
        metadata: { order_id: orderIdString },
        binary_mode: true,
      }
    });

    console.log('✅ Preference creada. ID:', response.id);

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
// WEBHOOK CON IDEMPOTENCIA (MODIFICADO PARA TEST LOCAL)
// =======================
export const processWebhook = async (req, res) => {
  let currentPaymentId = null;

  try {
    console.log('🪝 Webhook recibido body:', JSON.stringify(req.body, null, 2));
    console.log('🪝 Webhook recibido query:', req.query);

    const paymentId = req.body.data?.id || req.body.id || req.query.id || req.query['data.id'] || null;

    if (!paymentId) {
      console.log('❌ No se encontró paymentId');
      return res.sendStatus(200);
    }

    currentPaymentId = paymentId;
    console.log('📦 paymentId extraído:', paymentId);

    if (processedPayments.has(paymentId)) {
      console.log(`⏩ Webhook duplicado ignorado: ${paymentId}`);
      return res.sendStatus(200);
    }

    processedPayments.add(paymentId);
    console.log(`🪝 Procesando webhook por primera vez: ${paymentId}`);

    // 🛑 BYPASS PARA TEST LOCAL (Simulamos la respuesta de Mercado Pago sin ir a internet)
    console.log(`[TEST LOCAL] Simulando consulta de pago ID ${paymentId} sin llamar a MP.`);

    const paymentStatusSimulado = 'approved';

    // 4. Buscar la ÚLTIMA orden creada en la base de datos automáticamente
    const order = await Order.findOne().sort({ createdAt: -1 });

    if (order) {
      const orderId = order._id;
      const paymentStatus = paymentStatusSimulado;

      // Mapear detalles de pago falsificados para el test
      const paymentDetailsObject = {
        paymentId: paymentId,
        preferenceId: 'mock-pref-123',
        method: 'account_money',
        statusDetail: 'accredited',
      };

      // 5. Lógica de confirmación de pago
      if (paymentStatus === 'approved' && order.status !== 'PAID') {
        order.status = 'PAID';
        order.isPaid = true;
        order.paymentStatus = 'approved';
        order.paymentDetails = paymentDetailsObject;

        await order.save();
        console.log(`✅ [MP WEBHOOK ÉXITO] Orden ${orderId} actualizada a PAID en Base de Datos.`);

        // 🚀 EL ENCHUFE ASINCRÓNICO DE LOGÍSTICA
        console.log(`🚚 [LOGISTICA] Disparando proceso de envío para la orden: ${orderId}`);
        processOrderLogistics(order._id).catch(err => {
          console.error(`[LOGISTICA ERROR ASINCRÓNICO] Falló el proceso de envío para la orden ${order._id}:`, err.message);
        });

      } else if (paymentStatus === 'approved' && order.status === 'PAID') {
        console.log(`⏩ Orden ${orderId} ya estaba aprobada como PAID. Ignorando.`);
      } else {
        order.paymentDetails = paymentDetailsObject;
        await order.save();
        console.log(`[MP WEBHOOK INFO] Orden ${orderId} actualizada con estado MP: ${paymentStatus}`);
      }

      // 6. Respuesta OK
      return res.sendStatus(200);

    } else {
      console.error(`[MP WEBHOOK ERROR] No se encontró ninguna orden en la base de datos.`);
      return res.status(200).send('No hay órdenes en la DB.');
    }
  } catch (error) {
    console.error('❌ Error crítico en webhook:', error.message);
    if (currentPaymentId) {
      processedPayments.delete(currentPaymentId);
      console.log(`🗑️ Removido paymentId ${currentPaymentId} del Set debido a un error.`);
    }
    res.status(500).send('Internal Server Error');
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