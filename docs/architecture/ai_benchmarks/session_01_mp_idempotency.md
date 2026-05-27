# AI Evaluation - Session 01: Mercado Pago Webhook Idempotency

**Date:** 2026-05-23  
**Task:** Distributed Locking and Architecture Scaling  
**Models Evaluated:** Gemini 3 Flash (Playground)

---

## 1. The Input (The Benchmark Prompt)
(Acá pegás el prompt de estrés que guardamos en tu archivo .txt)

"Actúa como un QA Engineer experto en Node.js y pasarelas de pago. Estoy trabajando en la suite de pruebas de mi proyecto backend 'biye' (usando Jest). Tengo mi archivo centralizado de pruebas de integración en backend/tests/payment.service.test.js que cubre la idempotencia de los webhooks de Mercado Pago y las transiciones de estado de los pagos.

Quiero que me ayudes a expandir estos escenarios para cubrir fallos de red, payloads corruptos y respuestas inesperadas de la API externa.

A continuación, te voy a pasar primero el código de mi archivo de pruebas actual para que veas qué lógica tenemos armada y me digas qué nos falta. ¿Listo para que te pase el código?"
---

## 2. Model Output: Gemini 3 Flash
(Acá pegás el código y la explicación técnica que te tiró el modelo en el Playground)
## 2. Model Output: Gemini 3 Flash

### Proposed Distributed Implementation (Node.js + ioredis)
```javascript
import { redis } from '../config/redis.js';
import Order from '../models/order.js';

export const processWebhook = async (req, res) => {
  const { id: paymentId } = req.query || req.body.data;
  if (!paymentId) return res.sendStatus(200);

  // 1. DISTRIBUTED LOCK ACQUISITION (SETNX Pattern)
  const lockKey = `lock:webhook:${paymentId}`;
  const lockToken = process.env.HOSTNAME || 'node-instance'; 
  
  // NX: Only if not exists | PX: 10-second expiry window
  const locked = await redis.set(lockKey, lockToken, 'NX', 'PX', 10000);
  if (!locked) {
    return res.status(429).send('Conflict: Payment processing in progress');
  }

  try {
    // 2. FETCH PAYMENT DATA FROM PROVIDER
    const payment = await mercadopago.payment.get({ id: paymentId });
    const { external_reference: orderId, status: mpStatus } = payment;

    // 3. ATOMIC STATE TRANSITION WITH OCC (Belt and Suspenders)
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
      console.log(`[Webhook] Order ${orderId} already processed or missing.`);
      return res.sendStatus(200);
    }

    // 4. POST-PROCESSING (Async)
    await handlePostPaymentLogic(order);
    return res.sendStatus(200);

  } catch (error) {
    console.error(`[CRITICAL] Webhook Error: ${error.message}`);
    // Release lock on transient DB failures to allow immediate retry
    await redis.del(lockKey);
    return res.status(500).send('Internal Server Error');
  }
};

const mapStatus = (status) => {
  const mapping = { approved: 'paid', pending: 'processing', rejected: 'failed' };
  return mapping[status] || 'pending';
};
---
Key Architectural Notes Provided by the Model
Failsafe (The Double Check): Uses MongoDB's atomic findOneAndUpdate filtering by { paymentStatus: { $ne: 'paid' } } as an internal guard clause. Redis controls the request concurrency, the DB controls the resource state.

The "Ghost" Lock Risk: Warns against explicitly deleting the lock inside a global finally block. Rapid duplicate webhooks sent within milliseconds could bypass the safety window. Holding the lock for the full TTL silences provider retry noise.

Redlock (Future proofing): Highlights that single-node SETNX is vulnerable if Redis fails. To safely scale to a multi-node Redis cluster, the system must adapt the Redlock algorithm to coordinate locks across nodes.



## 3. Engineering Evaluation & Verdict (Tu Análisis)
* **Precisión Técnica [9/10]:** El modelo identificó correctamente la necesidad de un candado global (`SETNX`) y aplicó un "Double Check" en MongoDB (`{ paymentStatus: { $ne: 'paid' } }`). 
* **Manejo de Edge Cases:** Excelente observación sobre el "Ghost Lock". El modelo advirtió que no se debe borrar el candado inmediatamente con `redis.del` en el bloque `finally` para evitar que los reintentos rápidos de Mercado Pago generen ruido.
* **Puntos Débiles/Omisiones:** El modelo asumió una configuración de Redis de nodo único. Para un entorno de producción masivo, debió profundizar en la resiliencia del cluster usando el algoritmo `Redlock`.

**Verdict:** PRODUCTION-READY WITH RESERVATIONS (Requiere ajuste de Redlock para clusters).

* **Grok 4.1 Fast Cross-Evaluation [10/10]:** Sometido al mismo escenario de estrés, Grok identificó la "Ghost Write Race Condition" provocada por el borrado prematuro del candado en el bloque `catch`. Propuso mitigar el riesgo migrando a una arquitectura basada en colas asincrónicas (BullMQ), demostrando un entendimiento superior en resiliencia de sistemas distribuidos que Gemini 3 Flash.