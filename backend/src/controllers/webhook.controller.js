import asyncHandler from '../middleware/asyncHandler.middleware.js'; 
import Order from '../models/order.js'; 
// Importar dependencias con la sintaxis de ES Modules y asegurar el .js

/**
 * @desc    Maneja las notificaciones de Webhook de Mercado Pago
 * @route   POST /api/v1/payments/mercadopago-webhook
 * @access  Público (accedido por MP, no por el usuario final)
 */
export const handleMercadoPagoWebhook = asyncHandler(async (req, res, next) => {
// ^^^^^^ CRÍTICO: Exportación nombrada con "export const"
    // 1. Obtener datos de la notificación
    const { type, 'data.id': resourceId } = req.query;

    if (!type || !resourceId) {
        return res.status(200).send('Webhook recibido, parámetros de query faltantes.');
    }

    console.log(`[MP WEBHOOK] Recibida notificación. Tipo: ${type}, Recurso ID: ${resourceId}`);

    if (type !== 'payment') {
        return res.status(200).send('Tipo de notificación ignorado.');
    }

    // 2. Obtener el cliente de Pago inyectado
    const paymentClient = req.app.locals.PaymentClient;
    const paymentId = resourceId;

    if (!paymentClient) {
        console.error('[MP WEBHOOK ERROR] Cliente de Pago de Mercado Pago no configurado en app.locals.');
        throw new Error('Servidor: Cliente de Pago de Mercado Pago no configurado.');
    }

    let paymentDetails;
    try {
        // Usar el cliente inyectado correctamente para el SDK moderno
        paymentDetails = await paymentClient.get({ id: paymentId }); 
        console.log(`Pago ID ${paymentId} consultado. Estado: ${paymentDetails.status}`);
    } catch (error) {
        console.error(`[MP WEBHOOK ERROR] Fallo al consultar el pago ID ${paymentId}:`, error.message);
        return res.status(500).send('Error al consultar detalles de pago con MP.');
    }
    
    const payment = paymentDetails;
    
    // 3. Extraer ID de la orden interna
    const orderId = payment.external_reference; 

    if (!orderId) {
        console.warn(`[MP WEBHOOK WARNING] Pago ID ${paymentId} procesado, pero no se encontró 'external_reference' (Order ID).`);
        return res.status(200).send('Pago procesado, sin referencia de orden interna.');
    }

    // 4. Buscar y actualizar la orden en la base de datos
    const order = await Order.findById(orderId);

    if (order) {
        const paymentStatus = payment.status; // 'approved', 'pending', 'rejected', etc.

        // Mapear los detalles del pago
        const paymentDetailsObject = {
            paymentId: payment.id,
            // Usamos metadata.preference_id si existe
            preferenceId: payment.metadata?.preference_id, 
            method: payment.payment_type_id,
            statusDetail: payment.status_detail,
        };
        
        // 5. Lógica de confirmación de pago
        if (paymentStatus === 'approved' && order.status !== 'PAID') {
            order.status = 'PAID';
            order.paidAt = new Date(payment.date_approved || Date.now()); 
            order.paymentDetails = paymentDetailsObject; 
            
            await order.save();
            console.log(`[MP WEBHOOK ÉXITO] Orden ${orderId} actualizada a PAGADA. Estado MP: ${paymentStatus}`);
            
        } else if (paymentStatus === 'approved' && order.status === 'PAID') {
             console.log(`[MP WEBHOOK INFO] Orden ${orderId} ya estaba PAGADA. No se requiere acción.`);
        } else {
            // Actualizar el estado de pago, aunque no sea 'PAID' (ej: 'pending', 'rejected')
            order.paymentDetails = paymentDetailsObject;
            // Solo guardamos si hay un cambio significativo para no saturar
            if (JSON.stringify(order.paymentDetails) !== JSON.stringify(paymentDetailsObject)) {
                await order.save();
            }
            console.log(`[MP WEBHOOK INFO] Orden ${orderId} actualizada con estado MP: ${paymentStatus}`);
        }

        // 6. Respuesta CRÍTICA: Devolver 200 OK a Mercado Pago
        res.status(200).send('Notificación de pago procesada correctamente.');

    } else {
        console.error(`[MP WEBHOOK ERROR] Orden ${orderId} no encontrada en la base de datos.`);
        res.status(200).send('Orden no encontrada, pero notificación recibida.');
    }
});

