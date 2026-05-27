import asyncHandler from '../middleware/asyncHandler.middleware.js';
import Order from '../models/order.js';
// 🚚 IMPORTAMOS EL MANAGER DE LOGÍSTICA
import { processOrderLogistics } from '../services/shipping.manager.js';
// 🛑 IMPORTAMOS EL CLIENTE DE REDIS REAL
import redisClient from '../config/redis.js';
import { MercadoPagoConfig, Payment } from 'mercadopago';

const client = new MercadoPagoConfig({
    accessToken: process.env.MERCADOPAGO_ACCESS_TOKEN,
});

/**
 * @desc    Maneja las notificaciones de Webhook de Mercado Pago con Idempotencia en Redis
 * @route   POST /api/v1/payments/webhook
 * @access  Público (accedido por MP, no por el usuario final)
 */
export const handleMercadoPagoWebhook = asyncHandler(async (req, res, next) => {
    // 1. Obtener datos de la notificación
    const { type, 'data.id': resourceId } = req.query;

    if (!type || !resourceId) {
        return res.status(200).send('Webhook recibido, parámetros de query faltantes.');
    }

    console.log(`[MP WEBHOOK] Recibida notificación. Tipo: ${type}, Recurso ID: ${resourceId}`);

    if (type !== 'payment') {
        return res.status(200).send('Tipo de notificación ignorado.');
    }

    const paymentId = resourceId;

    // 🔑 2. Control de Idempotencia con Redis Real
    const redisKey = `webhook:payment:${paymentId}`;
    const isDuplicated = await redisClient.get(redisKey);

    if (isDuplicated) {
        console.log(`⏩ [REDIS IDEMPOTENCIA] Webhook duplicado ignorado de forma segura: ${paymentId}`);
        return res.status(200).send('Notificación duplicada ignorada de forma segura.');
    }

    // Guardamos el ID en Redis por 24 horas (86400 segundos) para bloquear duplicados
    await redisClient.set(redisKey, 'processed', {
        EX: 86400
    });
    console.log(`🪝 [REDIS REAL] Registrando nuevo webhook por primera vez: ${paymentId} (TTL: 24hs)`);

    // 🌟 3. Variables de control dinámicas (Híbrido Producción vs Test Local)
    let paymentStatus;
    let orderId;
    let paymentDetailsObject;

    if (process.env.NODE_ENV === 'production') {
        // 🌐 CÓDIGO REAL PARA PRODUCCIÓN (Consulta a la API de Mercado Pago)
        const paymentClient = new Payment(client);
        const payment = await paymentClient.get({ id: String(paymentId) });

        if (!payment || !payment.status) {
            console.log('❌ Payload de Mercado Pago corrupto o inesperado');
            await redisClient.del(redisKey); // Liberamos la clave si falló la consulta externa
            return res.status(400).send('Bad Request: Invalid MP Payload');
        }

        paymentStatus = payment.status;
        orderId = payment.external_reference || payment.metadata?.order_id;

        paymentDetailsObject = {
            paymentId: payment.id,
            preferenceId: payment.metadata?.preference_id || 'N/A',
            method: payment.payment_type_id || 'unknown',
            statusDetail: payment.status_detail || 'unknown',
        };
    } else {
        // 🛑 BYPASS AUTOMÁTICO PARA DESARROLLO LOCAL EN TU DEBIAN
        console.log(`[TEST LOCAL] Entorno de desarrollo detectado. Simulando datos.`);

        // Buscamos dinámicamente la última orden creada desde Postman para no hardcodear IDs
        const lastOrder = await Order.findOne().sort({ createdAt: -1 });
        if (!lastOrder) {
            console.error('[MP WEBHOOK ERROR] No hay órdenes en la base de datos local para testear.');
            await redisClient.del(redisKey);
            return res.status(200).send('No hay órdenes en la DB para procesar el test.');
        }

        paymentStatus = 'approved';
        orderId = lastOrder._id;

        paymentDetailsObject = {
            paymentId: paymentId,
            preferenceId: 'mock-pref-123',
            method: 'account_money',
            statusDetail: 'accredited',
        };
    }

    // 4. Buscar la orden correspondiente en la base de datos
    const order = await Order.findById(orderId);

    if (order) {
        console.log(`💰 Status del Pago: ${paymentStatus} | Orden ID: ${orderId}`);

        // 5. Lógica de confirmación de pago
        if (paymentStatus === 'approved' && order.status !== 'PAID') {
            order.status = 'PAID';
            order.isPaid = true; // Sincronizamos con el flag booleano de tu modelo
            order.paidAt = new Date();
            order.paymentStatus = 'approved';
            order.paymentDetails = paymentDetailsObject;

            await order.save();
            console.log(`✅ [MP WEBHOOK ÉXITO] Orden ${orderId} actualizada a PAGADA. Estado MP: ${paymentStatus}`);

            // 🚀 ENCHUFE DE LOGÍSTICA ASINCRÓNICA
            console.log(`🚚 [LOGISTICA] Disparando proceso de envío para la orden: ${orderId}`);
            processOrderLogistics(order._id).catch(err => {
                console.error(`[LOGISTICA ERROR ASINCRÓNICO] Falló el proceso de envío para la orden ${order._id}:`, err.message);
            });

        } else if (paymentStatus === 'approved' && order.status === 'PAID') {
            console.log(`⏩ [MP WEBHOOK INFO] Orden ${orderId} ya estaba PAGADA. No se requiere acción.`);
        } else {
            order.paymentDetails = paymentDetailsObject;
            order.paymentStatus = paymentStatus;
            await order.save();
            console.log(`[MP WEBHOOK INFO] Orden ${orderId} actualizada con estado MP: ${paymentStatus}`);
        }

        // 6. Respuesta OK a Mercado Pago
        return res.status(200).send('Notificación de pago procesada correctamente.');

    } else {
        console.error(`[MP WEBHOOK ERROR] Orden ${orderId} no encontrada en la base de datos.`);
        return res.status(200).send('Orden no encontrada, pero notificación recibida.');
    }
});