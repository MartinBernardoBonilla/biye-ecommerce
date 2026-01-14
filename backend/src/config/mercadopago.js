import { MercadoPagoConfig } from 'mercadopago';

if (!process.env.MERCADOPAGO_ACCESS_TOKEN) {
  throw new Error('❌ MERCADOPAGO_ACCESS_TOKEN NO DEFINIDO');
}

const mpClient = new MercadoPagoConfig({
  accessToken: process.env.MERCADOPAGO_ACCESS_TOKEN,
});

console.log('💳 Mercado Pago SDK listo');

export default mpClient;
