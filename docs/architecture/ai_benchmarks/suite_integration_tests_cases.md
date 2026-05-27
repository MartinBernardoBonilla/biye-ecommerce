# Current Resiliency Baseline: 15 Integration Tests Structure

This document logs the core edge-cases and error-handling tests implemented in `payment.service.test.js`. This is the operational baseline before migrating to a distributed system architecture.

---

## 1. External API Failures (Mercado Pago Downtime)
Handles network drops (500 errors) or malformed responses from the payment provider without crashing the Node.js process, ensuring proper 5xx responses so the provider retries the webhook later.

```javascript
describe('processWebhook - Fallos de API Externa', () => {
  test('debe manejar un error 500 de Mercado Pago (Network Error)', async () => {
    const { default: mp } = await import('mercadopago');
    const paymentInstance = new mp.Payment();
    paymentInstance.get.mockRejectedValueOnce(new Error('Internal Server Error MP'));
    const res = buildRes();

    await processWebhook({ body: { data: { id: 'pay-fail-500' } }, query: {} }, res);
    expect(res.status).toHaveBeenCalledWith(500); 
  });

  test('debe manejar una respuesta vacía o inesperada de la API de MP', async () => {
    mockPaymentData = { unexpected: 'format' }; 
    const res = buildRes();
    await processWebhook({ body: { data: { id: 'pay-weird' } }, query: {} }, res);

    expect(mockOrderSave).not.toHaveBeenCalled();
    expect(res.sendStatus).not.toHaveBeenCalledWith(200);
  });
});

2. Corrupt & Malformed Payloads (Security & Validation)
Guards the endpoint against malicious tracking injection or broken provider payloads where id or external_reference are missing.

JavaScript
describe('processWebhook - Payloads Corruptos', () => {
  test('debe ignorar webhooks con estructura de datos malformada', async () => {
    const res = buildRes();
    await processWebhook({ body: { data: { unknown_field: 'abc' } }, query: {} }, res);
        
    expect(res.sendStatus).toHaveBeenCalledWith(200); 
    expect(Order.findById).not.toHaveBeenCalled();
  });

  test('debe manejar external_reference mal formateado o inexistente en MP', async () => {
    mockPaymentData = { id: 'pay-no-ref', status: 'approved', external_reference: null };
    const res = buildRes();
    await processWebhook({ body: { data: { id: 'pay-no-ref' } }, query: {} }, res);
    expect(Order.findById).not.toHaveBeenCalled();
  });
});
3. Database Persistence Failures (State Consistency Rollback)
Critical Resilience Test: If MongoDB timeouts or drops connection during .save(), the system rolls back, ensures the request returns a failure code, and critically pops the paymentId out of the in-memory processing Cache (Set) to allow future retries to process successfully.

JavaScript
describe('updatePaymentStatus - Fallos de Base de Datos', () => {
  test('debe lanzar error si la base de datos falla al guardar', async () => {
    mockOrderData = buildOrder();
    mockOrderSave.mockRejectedValueOnce(new Error('DB Connection Timeout'));
    await expect(updatePaymentStatus('order-123', 'approved'))
      .rejects.toThrow('DB Connection Timeout');
  });

  test('no debe agregar el paymentId al Set de procesados si la DB falló', async () => {
    mockOrderData = buildOrder();
    mockOrderSave.mockRejectedValueOnce(new Error('DB Error'));
    const res = buildRes();
    await processWebhook({ body: { data: { id: 'pay-retry' } }, query: {} }, res);

    expect(processedPayments.has('pay-retry')).toBe(false);
  });
});
4. Unmapped Edge Case States
Ensures defensive handling for edge case webhooks or status changes (e.g., in_mediation) without leaving the checkout loop hanging.

JavaScript
describe('processWebhook - Estados no mapeados', () => {
  test('debe manejar estados desconocidos de Mercado Pago (ej: in_mediation)', async () => {
    mockOrderData = buildOrder();
    mockPaymentData = { id: 'pay-med', status: 'in_mediation', external_reference: 'order-123' };
    const res = buildRes();
    await processWebhook({ body: { data: { id: 'pay-med' } }, query: {} }, res);

    expect(mockOrderSave).toHaveBeenCalled(); 
  });
});