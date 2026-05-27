import asyncHandler from '../middleware/asyncHandler.middleware.js';
import Order from '../models/order.js';
// 🚚 IMPORTAMOS EL MANAGER DE LOGÍSTICA
import { processOrderLogistics } from '../services/shipping.manager.js';

/**
 * @desc    Maneja las notificaciones de Webhook de Mercado Pago
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

    // 🛑 BYPASS TEMPORAL PARA PRUEBAS LOCALES (Evita la consulta real a la API de MP que da error 404)
    console.log(`[TEST LOCAL] Simulando consulta de pago ID ${paymentId} sin llamar a MP.`);

    const paymentDetails = {
        id: paymentId,
        status: 'approved',
        external_reference: '6a1714bf360c416d04f80807', // Tu ID de orden real en MongoDB
        payment_type_id: 'account_money',
        status_detail: 'accredited',
        metadata: { preference_id: 'mock-pref-123' }
    };

    // 3. Configurar variables de control usando el Mock local
    const orderId = "6a1714bf360c416d04f80807"; // Forzamos tu ID real de base de datos
    const paymentStatusSimulado = 'approved';    // Forzamos el estado aprobado

    // 4. Buscar y actualizar la orden en la base de datos
    const order = await Order.findById(orderId);

    if (order) {
        const paymentStatus = paymentStatusSimulado;

        // Mapear los detalles del pago
        const paymentDetailsObject = {
            paymentId: paymentDetails.id,
            preferenceId: paymentDetails.metadata?.preference_id,
            method: paymentDetails.payment_type_id,
            statusDetail: paymentDetails.status_detail,
        };

        // 5. Lógica de confirmación de pago
        if (paymentStatus === 'approved' && order.status !== 'PAID') {
            order.status = 'PAID';
            order.paidAt = new Date();
            order.paymentDetails = paymentDetailsObject;

            await order.save();
            console.log(`[MP WEBHOOK ÉXITO] Orden ${orderId} actualizada a PAGADA. Estado MP: ${paymentStatus}`);

            // 🚀 ENCHUFE DE LOGÍSTICA ASINCRÓNICA
            // Se ejecuta en segundo plano. Si falla, el webhook responde 200 igual y no traba el flujo.
            processOrderLogistics(order._id).catch(err => {
                console.error(`[LOGISTICA ERROR ASINCRÓNICO] Falló el proceso de envío para la orden ${order._id}:`, err.message);
            });

        } else if (paymentStatus === 'approved' && order.status === 'PAID') {
            console.log(`[MP WEBHOOK INFO] Orden ${orderId} ya estaba PAGADA. No se requiere acción.`);
        } else {
            order.paymentDetails = paymentDetailsObject;
            await order.save();
            console.log(`[MP WEBHOOK INFO] Orden ${orderId} actualizada con estado MP: ${paymentStatus}`);
        }

        // 6. Respuesta CRÍTICA: Devolver 200 OK a Mercado Pago
        return res.status(200).send('Notificación de pago procesada correctamente.');

    } else {
        console.error(`[MP WEBHOOK ERROR] Orden ${orderId} no encontrada en la base de datos.`);
        return res.status(200).send('Orden no encontrada, pero notificación recibida.');
    }
});