// backend/src/services/shipping.manager.js
import Order from '../models/order.js';

// Aquí simularías o conectarías las APIs reales en el futuro
const carrierProviders = {
    andreani: {
        createShipment: async (order) => {
            // Aquí irá el fetch a la API de Andreani en el futuro
            // Por ahora devolvemos un Mock estándar de producción
            console.log(`[LOGISTICA] Conectando con API de Andreani para Orden: ${order._id}`);
            return {
                trackingNumber: `AND-${Math.floor(100000 + Math.random() * 900000)}`,
                labelUrl: `https://api.andreani.com/labels/mock-pdf-${order._id}.pdf`,
                status: 'ready_to_ship'
            };
        }
    },
    custom_moto: {
        createShipment: async (order) => {
            console.log(`[LOGISTICA] Registrando envío local en Moto para Orden: ${order._id}`);
            return {
                trackingNumber: `MOTO-${order.shipping.address.zipCode}-${Date.now().toString().slice(-4)}`,
                labelUrl: null,
                status: 'ready_to_ship'
            };
        }
    }
};

export const processOrderLogistics = async (orderId) => {
    try {
        const order = await Order.findById(orderId);
        if (!order) throw new Error('Orden no encontrada para logística');

        // Si es retiro por el local, no hay que generar etiquetas ni guías de correo
        if (order.shipping.method === 'pickup') {
            order.shipping.tracking.status = 'delivered'; // O listo para retirar
            await order.save();
            return { success: true, message: 'Retiro por local registrado' };
        }

        const provider = carrierProviders[order.shipping.carrierName];
        if (!provider) {
            throw new Error(`Proveedor de logística no soportado: ${order.shipping.carrierName}`);
        }

        // Ejecutamos la estrategia correspondiente (Andreani, Moto, etc.)
        const shipmentData = await provider.createShipment(order);

        // Actualizamos la orden de forma limpia
        order.shipping.tracking.trackingNumber = shipmentData.trackingNumber;
        order.shipping.tracking.labelUrl = shipmentData.labelUrl;
        order.shipping.tracking.status = shipmentData.status;

        await order.save();
        console.log(`[LOGISTICA SUCCESS] Orden ${orderId} despachada correctamente.`);
        return { success: true, trackingNumber: shipmentData.trackingNumber };

    } catch (error) {
        console.error(`[LOGISTICA ERROR] Falló el procesamiento de envío: ${error.message}`);
        // Aquí podrías marcar el tracking.status como 'failed' para que el Admin lo vea en su panel
        await Order.findByIdAndUpdate(orderId, { 'shipping.tracking.status': 'failed' });
        return { success: false, error: error.message };
    }
};