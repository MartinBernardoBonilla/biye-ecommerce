// src/services/inventory.service.js
import Product from '../models/Product.model.js';
import Order from '../models/Order.js'; 

/**
 * @description Maneja la lógica de negocio para actualizar una orden y el stock de productos
 * después de una notificación de pago exitoso.
 * @param {string} orderId - El ID de la orden de tu base de datos (MongoDB _id).
 * @param {object} paymentInfo - La información relevante del webhook de Mercado Pago (id, status, etc.)
 */
export const updateProductStock = async (orderId, paymentInfo) => {
    try {
        console.log(`[Inventory Service] Procesando orden ID: ${orderId}`);

        // 1. Encontrar la orden en la base de datos
        const order = await Order.findById(orderId);

        if (!order) {
            console.error(`[Inventory Service] Error: No se encontró la orden con ID ${orderId}`);
            // NOTA: Si no existe, podrías decidir crearla aquí, pero generalmente
            // la orden ya se creó cuando el usuario inició la compra.
            return;
        }

        // 2. Verificar si la orden ya fue pagada para evitar doble procesamiento
        if (order.isPaid) {
            console.log(`[Inventory Service] La orden ${orderId} ya había sido marcada como pagada. Terminando.`);
            return order;
        }

        // 3. ACTUALIZAR ESTADO DE PAGO DE LA ORDEN
        order.isPaid = true;
        order.paidAt = new Date(Date.now());
        // Guardar la información relevante del pago
        order.paymentResult = {
            id: paymentInfo.id,
            status: paymentInfo.status,
            email_payer: paymentInfo.email_payer,
        };

        // 4. DECREMENTAR EL STOCK DE CADA PRODUCTO EN LA ORDEN
        
        // Usamos un loop for...of para manejar operaciones asíncronas dentro (actualización de stock)
        for (const item of order.orderItems) {
            // El 'product' en item.product es el ObjectId del producto (gracias al esquema de Order)
            const productToUpdate = await Product.findById(item.product);

            if (productToUpdate) {
                // Verificar que la cantidad a decrementar no sea mayor que el stock actual
                if (productToUpdate.countInStock >= item.qty) {
                    productToUpdate.countInStock -= item.qty;
                    await productToUpdate.save();
                    console.log(`Stock actualizado para ${productToUpdate.name}. Nuevo stock: ${productToUpdate.countInStock}`);
                } else {
                    console.error(`ERROR DE STOCK: Stock insuficiente para ${productToUpdate.name}. Stock actual: ${productToUpdate.countInStock}, Solicitado: ${item.qty}`);
                    // Aquí podrías añadir lógica para marcar la orden como 'Problema de Stock'
                }
            } else {
                console.error(`Advertencia: Producto con ID ${item.product} no encontrado.`);
            }
        }

        // 5. Guardar la orden actualizada
        const updatedOrder = await order.save();
        console.log(`[Inventory Service] Orden ${orderId} marcada como PAGADA y stock actualizado.`);
        return updatedOrder;

    } catch (error) {
        console.error('[Inventory Service] Error grave al procesar el stock:', error);
        // NOTA: En un entorno de producción, aquí se enviaría un correo de alerta
        throw new Error('Fallo en la actualización de la orden y el stock.');
    }
};
