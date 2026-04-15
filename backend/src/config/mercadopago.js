import { MercadoPagoConfig } from 'mercadopago';

if (!process.env.MERCADOPAGO_ACCESS_TOKEN) {
  throw new Error('❌ MERCADOPAGO_ACCESS_TOKEN NO DEFINIDO');
}

const mpClient = new MercadoPagoConfig({
  accessToken: process.env.MERCADOPAGO_ACCESS_TOKEN,
});

// ✅ Solo mostrar que está configurado, NO el token
console.log('💳 Mercado Pago SDK listo');
console.log('💳 Modo:', process.env.MERCADOPAGO_ACCESS_TOKEN.startsWith('TEST-') ? 'TEST' : 'PROD');

export default mpClient;