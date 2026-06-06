import { jest } from '@jest/globals';

const mockOrderSave = jest.fn().mockResolvedValue(true);
let mockOrderData = null;
let mockPaymentData = {};
let shouldMPFail = false; // Control dinámico para hacer fallar a Mercado Pago

jest.unstable_mockModule('../src/models/order.js', () => ({
  default: {
    findById: jest.fn(),
    findOne: jest.fn(),
  },
}));

jest.unstable_mockModule('mercadopago', () => ({
  MercadoPagoConfig: jest.fn(),
  Preference: jest.fn(),
  Payment: jest.fn().mockImplementation(() => ({
    get: jest.fn().mockImplementation(async () => {
      if (shouldMPFail) {
        throw new Error('Internal Server Error MP');
      }
      return mockPaymentData;
    }),
  })),
}));

jest.unstable_mockModule('qrcode', () => ({
  default: { toDataURL: jest.fn().mockResolvedValue('data:image/png;base64,abc') },
}));

const { processWebhook, updatePaymentStatus, processedPayments, webhookCacheInterval } =
  await import('../src/services/payment.service.js');
const { default: Order } = await import('../src/models/order.js');

const buildRes = () => ({
  sendStatus: jest.fn(),
  status: jest.fn().mockReturnThis(),
  send: jest.fn(),
});

const buildOrder = (o = {}) => ({
  _id: 'order-123',
  paymentStatus: 'pending',
  isPaid: false,
  status: 'PENDING',
  save: mockOrderSave,
  ...o,
});

beforeEach(() => {
  jest.clearAllMocks();
  processedPayments.clear();
  shouldMPFail = false;
  mockPaymentData = {};

  const mockQuery = (data) => ({
    sort: jest.fn().mockResolvedValue(data),
  });

  Order.findById.mockImplementation(() =>
    mockOrderData ? { ...mockOrderData, save: mockOrderSave } : null
  );
  Order.findOne.mockImplementation(() =>
    mockQuery(mockOrderData ? { ...mockOrderData, save: mockOrderSave } : null)
  );
});

afterAll(() => {
  clearInterval(webhookCacheInterval);
});

describe('processWebhook', () => {
  test('responde 200 si no viene paymentId', async () => {
    const res = buildRes();
    await processWebhook({ body: {}, query: {} }, res);
    expect(res.sendStatus).toHaveBeenCalledWith(200);
  });

  test('actualiza la orden cuando el pago es approved', async () => {
    mockOrderData = buildOrder();
    mockPaymentData = { id: 'pay-1', status: 'approved', external_reference: 'order-123' };
    const res = buildRes();
    await processWebhook({ body: { data: { id: 'pay-1' } }, query: {} }, res);
    expect(mockOrderSave).toHaveBeenCalled();
    expect(res.sendStatus).toHaveBeenCalledWith(200);
  });

  test('no sobreescribe una orden ya aprobada', async () => {
    // 🎯 FIX: Agregamos status: 'PAID' para que el objeto simulado refleje una orden completada real
    mockOrderData = buildOrder({ paymentStatus: 'approved', isPaid: true, status: 'PAID' });
    mockPaymentData = { id: 'pay-2', status: 'approved', external_reference: 'order-123' };
    const res = buildRes();
    await processWebhook({ body: { data: { id: 'pay-2' } }, query: {} }, res);
    expect(mockOrderSave).not.toHaveBeenCalled();
    expect(res.sendStatus).toHaveBeenCalledWith(200);
  });

  test('responde 200 si la orden no existe', async () => {
    mockOrderData = null;
    mockPaymentData = { id: 'pay-3', status: 'approved', external_reference: 'x' };
    const res = buildRes();
    await processWebhook({ body: { data: { id: 'pay-3' } }, query: {} }, res);
    expect(mockOrderSave).not.toHaveBeenCalled();
    expect(res.sendStatus).toHaveBeenCalledWith(200);
  });

  test('extrae paymentId desde query string', async () => {
    mockOrderData = buildOrder();
    mockPaymentData = { id: 'pay-4', status: 'pending', external_reference: 'order-123' };
    const res = buildRes();
    await processWebhook({ body: {}, query: { id: 'pay-4' } }, res);
    expect(res.sendStatus).toHaveBeenCalledWith(200);
  });
});

describe('updatePaymentStatus', () => {
  test('retorna success true cuando status es approved', async () => {
    mockOrderData = buildOrder();
    const result = await updatePaymentStatus('order-123', 'approved');
    expect(mockOrderSave).toHaveBeenCalled();
    expect(result.success).toBe(true);
  });

  test('lanza error si la orden no existe', async () => {
    mockOrderData = null;
    await expect(updatePaymentStatus('x', 'approved')).rejects.toThrow('Orden no encontrada');
  });

  test('isPaid es false cuando status es rejected', async () => {
    const order = buildOrder();
    mockOrderData = order;
    Order.findById.mockReturnValueOnce({ ...order, save: mockOrderSave });
    await updatePaymentStatus('order-123', 'rejected');
    expect(order.isPaid).toBe(false);
  });
});

describe('processedPayments — idempotencia de Set', () => {
  test('un mismo paymentId no se procesa dos veces', async () => {
    const res1 = { sendStatus: jest.fn(), send: jest.fn() };
    const res2 = { sendStatus: jest.fn(), send: jest.fn() };

    // 1. Primer envío: Procesa pago + dispara logística asincrónica
    await processWebhook({ body: { data: { id: 'pay-dup' } }, query: {} }, res1);

    // 🧼 Limpiamos el contador del espía para ignorar lo que haya hecho el primer flujo
    mockOrderSave.mockClear();

    // 2. Segundo envío: Debería ser ignorado por el Set de idempotencia
    await processWebhook({ body: { data: { id: 'pay-dup' } }, query: {} }, res2);

    // Ahora validamos que el segundo webhook NO haya llamado a guardar nada nuevo
    expect(mockOrderSave).toHaveBeenCalledTimes(0);
  });

  test('processedPayments.clear() limpia el cache correctamente', () => {
    processedPayments.add('pay-test-1');
    processedPayments.add('pay-test-2');
    expect(processedPayments.size).toBe(2);
    processedPayments.clear();
    expect(processedPayments.size).toBe(0);
  });
});

describe('processWebhook - Fallos de API Externa', () => {
  test('debe manejar un error 500 de Mercado Pago (Network Error)', async () => {
    // Activamos la bandera para que el mock general tire la excepción
    shouldMPFail = true;

    const res = buildRes();
    await processWebhook({ body: { data: { id: 'pay-fail-500' } }, query: {} }, res);

    expect(res.status).toHaveBeenCalledWith(500);
  });

  test('debe manejar una respuesta vacía o inesperada de la API de MP', async () => {
    mockPaymentData = { unexpected: 'format' };
    const res = buildRes();

    await processWebhook({ body: { data: { id: 'pay-weird' } }, query: {} }, res);

    expect(mockOrderSave).not.toHaveBeenCalled();
    expect(res.status).toHaveBeenCalledWith(400);
  });
});

describe('processWebhook - Payloads Corruptos', () => {
  test('debe ignorar webhooks con estructura de datos malformada', async () => {
    const res = buildRes();
    await processWebhook({ body: { data: { unknown_field: 'abc' } }, query: {} }, res);

    expect(res.sendStatus).toHaveBeenCalledWith(200);
    expect(Order.findById).not.toHaveBeenCalled();
  });
});

describe('updatePaymentStatus y Webhook - Fallos de Base de Datos', () => {
  test('debe lanzar error si la base de datos falla al guardar', async () => {
    mockOrderData = buildOrder();
    mockOrderSave.mockRejectedValueOnce(new Error('DB Connection Timeout'));

    await expect(updatePaymentStatus('order-123', 'approved'))
      .rejects.toThrow('DB Connection Timeout');
  });

  test('no debe agregar el paymentId al Set de procesados si la DB falló', async () => {
    mockPaymentData = { id: 'pay-retry', status: 'approved', external_reference: 'order-123' };
    mockOrderData = buildOrder();
    mockOrderSave.mockRejectedValueOnce(new Error('DB Error'));

    const res = buildRes();
    await processWebhook({ body: { data: { id: 'pay-retry' } }, query: {} }, res);

    expect(processedPayments.has('pay-retry')).toBe(false);
    expect(res.status).toHaveBeenCalledWith(500);
  });
});