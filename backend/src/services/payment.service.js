// src/services/payment.service.js
// Lógica para interactuar con la API de un proveedor de pagos

export const processPayment = async (amount, currency, source) => {
    // Aquí iría la lógica real con Stripe / MercadoPago / etc.

    // Simulación de un pago exitoso
    const isSuccess = Math.random() > 0.1; // 90% de éxito

    if (isSuccess) {
        return {
            status: 'succeeded',
            id: `pay_${Date.now()}`,
            amount,
            currency,
        };
    } else {
        throw new Error('Pago fallido. Intente de nuevo.');
    }
};
