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
// WEBHOOK CON IDEMPOTENCIA (SOPORTE DE TEST INTEGRADO)
// =======================
export const processWebhook = async (req, res) => {
  let currentPaymentId = null;

  try {
    console.log('🪝 Webhook recibido body:', JSON.stringify(req.body, null, 2));
    console.log('🪝 Webhook recibido query:', req.query);

    const paymentId = req.body.data?.id || req.body.id || req.query.id || req.query['data.id'] || null;

    if (!paymentId) {
      console.log('❌ No se encontró paymentId');
      return res.sendStatus(200); // Satisface test "responde 200 si no viene paymentId"
    }

    currentPaymentId = paymentId;
    console.log('📦 paymentId extraído:', paymentId);

    if (processedPayments.has(paymentId)) {
      console.log(`⏩ Webhook duplicado ignorado: ${paymentId}`);
      return res.sendStatus(200);
    }

    processedPayments.add(paymentId);
    console.log(`🪝 Procesando webhook por primera vez: ${paymentId}`);

    let paymentStatus;
    let order;
    let paymentDetailsObject;

    // 🔀 BIFURCACIÓN DE ENTORNO: Desarrollo manual vs Suite de Tests o Producción
    if (process.env.NODE_ENV === 'development') {
      // 🛑 BYPASS LOCAL (Tu flujo cómodo en Debian)
      console.log(`[TEST LOCAL] Simulando consulta de pago ID ${paymentId} sin llamar a MP.`);
      paymentStatus = 'approved';
      order = await Order.findOne().sort({ createdAt: -1 });

      paymentDetailsObject = {
        paymentId: paymentId,
        preferenceId: 'mock-pref-123',
        method: 'account_money',
        statusDetail: 'accredited',
      };
    } else {
      // 🧪 MODO TEST / PRODUCCIÓN: Consumo dinámico de la API de Mercado Pago
      console.log(`[PROD/TEST] Consultando estado oficial en MP para ID: ${paymentId}`);

      const payment = new Payment(client);
      const paymentData = await payment.get({ id: paymentId }); // Si shouldMPFail es true, acá rompe e irá al catch (500)

      paymentStatus = paymentData?.status;
      const externalReference = paymentData?.external_reference;

      // Validación para respuestas inesperadas o malformadas de la API externa
      if (!externalReference || !paymentStatus) {
        console.log(`[MP WEBHOOK] Formato de pago inválido o sin external_reference para ID: ${paymentId}`);
        return res.status(400).send('Bad Request'); // Satisface test "debe manejar una respuesta vacía o inesperada"
      }

      order = await Order.findById(externalReference);

      // Si la orden no existe, devolvemos 200 OK para frenar los reintentos automáticos de la pasarela de pagos
      if (!order) {
        console.error(`[MP WEBHOOK ERROR] La orden ${externalReference} no existe en la Base de Datos.`);
        return res.sendStatus(200); // Satisface test "responde 200 si la orden no existe"
      }

      paymentDetailsObject = {
        paymentId: paymentId,
        preferenceId: paymentData.preference_id || 'prod-pref-id',
        method: paymentData.payment_method_id || 'unknown_method',
        statusDetail: paymentData.status_detail || 'accredited',
      };
    }

    // LÓGICA DE CONFIRMACIÓN Y MÁQUINA DE ESTADOS (Idéntica en ambos entornos)
    if (order) {
      const orderId = order._id;

      if (paymentStatus === 'approved' && order.status !== 'PAID') {
        order.status = 'PAID';
        order.isPaid = true;
        order.paymentStatus = 'approved';
        order.paymentDetails = paymentDetailsObject;

        await order.save(); // Si explota la DB, salta al catch y borra el Set para reintentos
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

      return res.sendStatus(200);
    }
  } catch (error) {
    console.error('❌ Error crítico en webhook:', error.message);

    // 🛡️ Si falló la persistencia (DB) o la red, removemos el ID del Set para habilitar reintentos en el próximo webhook
    if (currentPaymentId) {
      processedPayments.delete(currentPaymentId);
      console.log(`🗑️ Removido paymentId ${currentPaymentId} del Set debido a un error de ejecución.`);
    }

    // Satisface tests "debe manejar un error 500" y "no debe agregar el paymentId al Set si la DB falló"
    if (res.status) {
      return res.status(500).send('Internal Server Error');

    }
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