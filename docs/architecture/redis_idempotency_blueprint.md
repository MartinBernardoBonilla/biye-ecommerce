# Distributed Idempotency Blueprint (Future Scaling)

> "Actualmente el backend corre en una sola instancia con un cache local por un tema de costos de infraestructura. Pero dejé asentado el diseño con Redis porque sé que en un entorno real con escalabilidad horizontal, el estado en memoria local genera condiciones de carrera y la idempotencia se debe resolver con un Distributed Lock (SETNX)."

---

## 1. El Problema con el Escalado Horizontal
Al levantar múltiples instancias del backend de Node.js detrás de un Load Balancer, el `Set` en memoria local deja de ser efectivo. Si dos webhooks idénticos impactan en instancias distintas al mismo tiempo, ambas procesarán el pago en paralelo, rompiendo la consistencia de los datos.

## 2. Estrategia de Bloqueo Distribuido (Redis SETNX)
Para solucionarlo, se migrará a una capa de idempotencia global usando **Redis**:
* **Garantía Atómica:** Se utiliza el comando `SET` con las opciones `NX` (Not eXists) y `PX` (TTL en milisegundos).
* **Control de Fallos (TTL):** El candado se configura con un tiempo de vida (ej. 10 segundos). Si la instancia que tomó el pago se cae, el candado expira solo y el sistema puede reintentar sin quedar en *deadlock*.
* **Capa de Seguridad DB:** Se mantiene el chequeo optimista en MongoDB (`{ paymentStatus: { $ne: 'paid' } }`) como segunda línea de defensa.

## 3. Pseudocódigo de Producción (Node.js + ioredis)

```javascript
/**
 * processWebhook - Versión Distribuida con Redis
 * Arquitectura para Escalabilidad Horizontal
 */
import { redis } from '../config/redis.js';
import Order from '../models/order.js';

export const processWebhook = async (req, res) => {
  const { id: paymentId } = req.query || req.body.data;
  if (!paymentId) return res.sendStatus(200);

  // 1. ADQUISICIÓN DEL CANDADO DISTRIBUIDO
  const lockKey = `lock:webhook:${paymentId}`;
  const lockToken = process.env.HOSTNAME || 'node-instance'; 
  
  // NX: Solo si no existe | PX: Expira en 10000ms
  const locked = await redis.set(lockKey, lockToken, 'NX', 'PX', 10000);
  
  if (!locked) {
    // Otra instancia está procesando este pago actualmente.
    return res.status(429).send('Conflict: Payment processing in progress');
  }

  try {
    // 2. CONSULTA API EXTERNA (Mercado Pago)
    const payment = await mercadopago.payment.get({ id: paymentId });
    const { external_reference: orderId, status: mpStatus } = payment;

    // 3. TRANSICIÓN ATÓMICA EN MONGODB (Belt and Suspenders)
    const order = await Order.findOneAndUpdate(
      { 
        _id: orderId, 
        paymentStatus: { $ne: 'paid' } 
      },
      { 
        $set: { 
          paymentStatus: mapStatus(mpStatus),
          updatedAt: new Date(),
          lastPaymentEventId: paymentId
        }
      },
      { new: true }
    );

    if (!order) {
      // El pedido ya fue pagado o no existe
      console.log(`[Webhook] Order ${orderId} already processed or missing.`);
      return res.sendStatus(200);
    }

    // 4. LÓGICA POST-PAGO (Email, Stock, etc.)
    await handlePostPaymentLogic(order);
    return res.sendStatus(200);

  } catch (error) {
    console.error(`[CRITICAL] Webhook Error: ${error.message}`);
    // Si hay un error transitorio de DB, liberamos el candado para permitir reintento rápido
    await redis.del(lockKey);
    return res.status(500).send('Internal Server Error');
  }
};

const mapStatus = (status) => {
  const mapping = {
    approved: 'paid',
    pending: 'processing',
    rejected: 'failed'
  };
  return mapping[status] || 'pending';
};
