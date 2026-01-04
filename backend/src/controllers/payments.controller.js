import { MercadoPagoConfig, Preference, Payment } from 'mercadopago';
import Order from '../models/Order.js';  // 👈 IMPORTA TU MODELO

// Configuración de Mercado Pago
const ACCESS_TOKEN = process.env.MERCADOPAGO_ACCESS_TOKEN;
if (!ACCESS_TOKEN) {
  console.error("❌ Falta MERCADOPAGO_ACCESS_TOKEN en el .env");
}
const mpClient = new MercadoPagoConfig({ accessToken: ACCESS_TOKEN });

/**
 * Crear orden de pago
 */
export const createOrder = async (req, res) => {
  try {
    const { items, userEmail, orderId } = req.body;

    const preference = new Preference(mpClient);

    const body = {
      items: items.map(i => ({
        title: i.title,
        unit_price: i.unit_price,
        quantity: i.quantity,
        currency_id: "ARS",
      })),
      payer: { email: userEmail || "comprador@biye.com" },
      back_urls: {
        success: `${process.env.FRONTEND_URL}/payment/success?orderId=${orderId}`,
        failure: `${process.env.FRONTEND_URL}/payment/failure?orderId=${orderId}`,
        pending: `${process.env.FRONTEND_URL}/payment/pending?orderId=${orderId}`,
      },
      auto_return: "approved",
      external_reference: orderId?.toString() || `ORDER-${Date.now()}`,
      notification_url: `${process.env.NGROK_BASE_URL}/api/v1/payments/mercadopago-webhook`,
    };

    const result = await preference.create({ body });

    console.log(`✅ Preferencia creada: ${result.id}`);

    return res.status(200).json({
      preferenceId: result.id,
      initPoint: result.init_point,
    });
  } catch (error) {
    console.error("❌ Error al crear preferencia:", error);
    return res.status(500).json({ error: "Error al crear la orden de pago." });
  }
};

/**
 * Webhook de Mercado Pago
 */
export const handleMercadoPagoWebhook = async (req, res) => {
  try {
    console.log("\n📩 Webhook recibido:", req.body);

    const resourceId = req.query.id || req.body.data?.id;
    if (!resourceId) return res.sendStatus(200);

    const payment = new Payment(mpClient);
    const paymentInfo = await payment.get({ id: resourceId });

    console.log("💳 Info del pago:", {
      id: paymentInfo.id,
      status: paymentInfo.status,
      external_reference: paymentInfo.external_reference,
    });

    // 🔥 Actualiza el estado del pedido en MongoDB
    const updatedOrder = await Order.findOneAndUpdate(
      { external_reference: paymentInfo.external_reference },
      { paymentStatus: paymentInfo.status, paymentId: paymentInfo.id },
      { new: true }
    );

    if (updatedOrder) {
      console.log(`✅ Pedido ${updatedOrder._id} actualizado a: ${paymentInfo.status}`);
    } else {
      console.warn("⚠️ No se encontró la orden asociada al pago.");
    }

    return res.sendStatus(200);
  } catch (error) {
    console.error("❌ Error procesando webhook MP:", error.message);
    return res.sendStatus(500);
  }
};
