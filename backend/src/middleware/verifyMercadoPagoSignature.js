export const verifyMercadoPagoSignature = (req, res, next) => {
  // Por ahora, solo logueamos que recibimos el webhook
  // En producción, implementar verificación completa con crypto
  console.log('🔔 Webhook recibido de MercadoPago');
  next();
};
