import { MercadoPagoConfig } from 'mercadopago';

if (!process.env.MERCADOPAGO_ACCESS_TOKEN) {
  throw new Error('❌ MERCADOPAGO_ACCESS_TOKEN NO DEFINIDO');
}

const mpClient = new MercadoPagoConfig({
  accessToken: process.env.MERCADOPAGO_ACCESS_TOKEN,
});

console.log('💳 Mercado Pago SDK listo');

console.log(
  '💳 MP ACCESS TOKEN:',
  process.env.MERCADOPAGO_ACCESS_TOKEN?.slice(0, 10),
);


export default mpClient;
