// src/config/mercadopago.js
import { MercadoPagoConfig } from 'mercadopago';

// Verifica que la variable de entorno crítica esté presente
if (!process.env.MP_ACCESS_TOKEN) {
    console.error("⛔️ ERROR CRÍTICO: La variable de entorno MP_ACCESS_TOKEN no está definida.");
    // No detenemos el proceso aquí, pero emitimos la advertencia.
}

// Inicializa el cliente de Mercado Pago
const mpClient = new MercadoPagoConfig({ 
    // Asegúrate de que process.env.MP_ACCESS_TOKEN esté cargado por 'dotenv/config'
    accessToken: process.env.MP_ACCESS_TOKEN,
    // Puedes configurar opciones adicionales aquí si es necesario
    options: { timeout: 5000 }
});

// Usamos EXPORTACIÓN POR DEFECTO para que 'import MercadoPagoClient from ...' funcione.
export default mpClient;
