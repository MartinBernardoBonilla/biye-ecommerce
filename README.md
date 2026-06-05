<div align="center">

# 🛒 **BIYE** <sub><sub>v1.0</sub></sub>

### Production-Oriented Fullstack Mobile E-Commerce Platform

[![Flutter](https://img.shields.io/badge/Flutter-3.41-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Node.js](https://img.shields.io/badge/Node.js-20-339933?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org)
[![MongoDB](https://img.shields.io/badge/MongoDB-8.0-47A248?style=for-the-badge&logo=mongodb&logoColor=white)](https://mongodb.com)
[![Redis](https://img.shields.io/badge/Redis-7.0-DC382D?style=for-the-badge&logo=redis&logoColor=white)](https://redis.io)
[![Mercado Pago](https://img.shields.io/badge/Mercado%20Pago-Integrado-009EE3?style=for-the-badge&logo=mercadopago&logoColor=white)](https://www.mercadopago.com.ar)

**Resilient Payment Processing · Event-Driven Reconciliation · Distributed State Consistency**

</div>

---

## Overview

**Biye** is a production-oriented fullstack mobile e-commerce platform designed to address real-world distributed payment consistency challenges.

The system focuses on fault-tolerant checkout orchestration by combining webhook-driven payment confirmation, polling-based reconciliation, idempotent transaction processing, and eventual consistency guarantees.

It was built to solve reliability issues commonly found in asynchronous payment systems such as delayed confirmations, duplicated notifications, interrupted checkout flows, and state desynchronization between client and backend.

---

## Live Demo

- **Frontend (Web)**  
https://biye-app-final.vercel.app

- **Backend API**  
https://biye-ecommerce-production.up.railway.app

---

## Engineering Focus

Biye explores distributed systems concepts applied to payment infrastructure:

- Event-driven payment confirmation
- Polling fallback reconciliation
- Idempotent transaction processing
- Eventual consistency
- Deterministic conflict resolution
- Fault-tolerant checkout recovery

---

## System Architecture

```text
Flutter Client
     │
     ▼
Node.js / Express REST API
     │
     ├── MongoDB
     │     ├── Users
     │     ├── Orders
     │     └── Payment States
     │
     ├── Mercado Pago API
     │       │
     │       └── Webhook Events
     │
     └── Polling Reconciliation Layer
```

---

## Screenshots

<div align="center">

| Home | Products / Favorites |
|:---:|:---:|
| ![Home](https://res.cloudinary.com/dwchpxcrv/image/upload/imagen1_qezswq.jpg) | ![Products](https://res.cloudinary.com/dwchpxcrv/image/upload/imagen_u19ub1.jpg) |

</div>

---

## Demo Flows

<div align="center">

### Add to Cart
<img src="./assets/carrito_new.gif" width="280"/>

### Checkout Flow
<img src="./assets/checkout_new.gif" width="280"/>

### Payment Lifecycle
<img src="./assets/output_final.gif" width="280"/>

</div>

Visual demonstrations of product selection, checkout orchestration, and asynchronous payment reconciliation.

---

## Core Features

### Payment Infrastructure
- Mercado Pago QR payments
- Online card checkout
- Webhook-first confirmation
- Polling reconciliation fallback
- Idempotent payment event processing
- Sandbox & production support

### Commerce Features
- Product catalog
- Shopping cart
- Favorites
- Checkout flow
- Order lifecycle management
- Address handling
- Payment method selection

### Security & Reliability
- JWT authentication
- Session persistence
- Rate limiting
- Defensive error handling
- Async state synchronization

### Frontend Architecture
- Flutter + Dart
- BLoC state management
- Clean Architecture
- Modular feature-based structure

---

## Distributed Payment Consistency Design

### 1. Webhook-First Confirmation

Mercado Pago sends asynchronous payment notifications.

The backend processes these events and updates order state.

---

### 2. Polling-Based Reconciliation

If webhook delivery is delayed or fails:

- Client polls payment status
- Backend queries Mercado Pago directly
- State is reconciled automatically

---

### 3. Idempotent Event Processing

Duplicate payment notifications are safely ignored using unique payment identifiers.

This prevents duplicated order transitions.

---

### 4. Eventual Consistency

The payment provider is treated as the source of truth.

Database state converges toward provider-confirmed state through reconciliation.

---

### 5. Conflict Resolution

Order state precedence:

```text
pending < processing < paid < failed
```

The most advanced valid provider state always prevails.

---

---

## Technical Challenges Solved

Implementing a bulletproof asynchronous payment lifecycle exposed several real-world edge cases. Below is the detailed breakdown of how we engineered the system to achieve production-grade stability across Dart Web and Node.js:

### 1. Fallback Type-Safety for In-Store Pickups (Dart Web)
* **The Problem:** When an order was placed using the **In-Store Pickup (Pickup)** logistics method, the backend omitted residential shipping properties, returning them as `null` inside the payload. This triggered a strict type-safety exception in Dart Web (`Null is not a subtype of String`), crashing the entire Order Details view before it could even mount.
* **The Solution:** We re-engineered the `OrderShipping.fromJson` factory constructor to perform smart, declarative data decoupling. If a `pickup` method is detected, or if key address properties are missing, the initialization of the nested `Address` entity is safely bypassed and assigned to `null`. This shields the UI from unexpected null-pointer runtime crashes while cleanly rendering store-collection workflows.

### 2. Overriding Restrictive HTTP Browser Caching (304 Not Modified)
* **The Problem:** During rapid client-side polling loops, modern web browsers aggressively cached the payment verification endpoints, continuously serving a stale `304 Not Modified` header. This froze the UI inside the "Waiting for Confirmation" loader indefinitively, even after the payment transaction had already been successfully processed and accredited on the database.
* **The Solution:** We broke the restrictive browser caching layer by injecting a dynamic, unique millisecond timestamp query parameter into the network request URI within the Remote Data Source Layer (`$baseUrl/api/v1/orders/$orderId?t=$timestamp`). This explicit mutation forces the client browser to bypass its internal cache and pull a fresh, veridical state from the database on every single iteration loop.

### 3. Webhook Security Architecture for External Payment Gateways
* **The Problem:** Mercado Pago asynchronous webhooks notify our servers externally upon successful payment events. Because our generic endpoint architecture was universally guarded by a strict JSON Web Token (JWT) authentication middleware (`protect`), these automated external gateway callbacks were systematically rejected with `401 Unauthorized` errors.
* **The Solution:** We decoupled the webhook route structure in the payment router (`router.post('/webhook', mercadoPagoWebhook);`), exposing it as a secure public route to handle unhindered incoming server-to-server payloads directly from Mercado Pago's cloud. Conversely, the manual state fallback route (`/api/v1/payments/update-status`) remains safely guarded under the global auth middleware, restricting override privileges strictly to authenticated platform administrators.

### 📊 Production-Ready Order Lifecycle UI
Once the distributed synchronization completes, the platform cleanly flushes the state machine, wipes the navigation history stack to prevent duplicate form submissions, and mounts the verified timeline overview:

<div align="center">
  <img src="https://res.cloudinary.com/dwchpxcrv/image/upload/Captura_desde_2026-06-04_15-44-15_bdsdkj.png"/>
  
  *Figure: Fully parsed, type-safe Order Detail view executing a zero-cost In-Store Pickup timeline.*
</div>

---

## Tech Stack

### Frontend
- Flutter
- Dart
- BLoC

### Backend
- Node.js
- Express
- MongoDB
- Redis

### Infrastructure
- Docker
- Railway
- Vercel

### Payments
- Mercado Pago API

---

## Automated Testing
[![Tests](https://img.shields.io/badge/tests-40_passing-brightgreen?style=for-the-badge)]()

| Type | Count | Coverage |
|------|------:|---------|
| Unit Tests (Flutter) | 17 | Cart logic, validation, pricing rules |
| Widget Tests (Flutter) | 9 | UI rendering, user interactions |
| Integration Tests (Node.js) | 15 | Webhook idempotency, MP API failures (500), corrupt payloads (400), DB resilience, and state transitions |

### Run Tests

```bash
# Frontend
cd frontend
flutter test

# Backend
cd backend
npm run test
```

---

## 🪝 Local Development & Payment Testing (Mercado Pago Webhook)

To facilitate local development (`development`) without depending on tunnels like Ngrok or real Mercado Pago API calls, the backend includes a **Dynamic Bypass** that simulates the complete order lifecycle and its subsequent approval.

### 🔄 Flow Architecture (Smoke Test)

The local test circuit synchronously and asynchronously validates order creation, Redis idempotency control, and logistics dispatch.

```text
[Flutter Web / Postman] ──(Create Order)──> [POST /api/v1/orders] ──> State: PENDING
                                                                           │
[Postman Webhook Sim]   ──(Trigger MP)──>  [POST /payments/webhook]        │ (Fetches latest)
                                                   │                       ▼
                                           (Redis Idempotency) ──> [Updates to PAID]
                                                                           │
                                                                           ▼
                                                                  [⚡ Shipping Manager]
```

### 🛠️ Smoke Test Step-by-Step

Follow these steps strictly to test system reactivity in your development environment:

#### 1. Create a Pending Order

Fire an HTTP request to generate an order in `PENDING` state. This can be done from the Flutter interface or directly via Postman:

- **Endpoint:** `POST http://localhost:5000/api/v1/orders`
- **Headers:** `Authorization: Bearer <JWT_TOKEN>`
- **Body (JSON):**

```json
{
  "currency": "ARS",
  "items": [
    {
      "productId": "69a120ea861c2de7697950ce",
      "name": "Remera Biye Test Logistica",
      "quantity": 1,
      "unitPrice": 15000
    }
  ]
}
```

- **Expected response:** `201 Created` (returns the order object with its `_id`).

#### 2. Simulate the Mercado Pago Notification (Webhook)

Once the pending order is created, send the notification event simulating the payment gateway behavior:

- **Endpoint:** `POST http://localhost:5000/api/v1/payments/webhook`
- **Query Params:**
  - `type`: `payment`
  - `data.id`: `[Unique_Random_Number]` (e.g. `951753852`)
- **Headers:** None required (public access)
- **Body:** Empty `{}`

> ⚠️ **Idempotency Note:** If you use a `data.id` that was already processed in the last 24 hours, Redis will block the request returning a safe duplicate state (`200 OK` without reprocessing). Make sure to change the number on each test run.

#### 3. Verify in the Backend Console

If the flow is correct, the Node.js terminal will log the following exact sequence:

```text
[MP WEBHOOK] Recibida notificación. Tipo: payment, Recurso ID: 951753852
🪝 [REDIS REAL] Registrando nuevo webhook por primera vez: 951753852 (TTL: 24hs)
[TEST LOCAL] Entorno de desarrollo detectado. Simulando datos.
💰 Status del Pago: approved | Orden ID: 6a18514aea8181de46097cfe
✅ [MP WEBHOOK ÉXITO] Orden 6a18514aea8181de46097cfe actualizada a PAID en Base de Datos.
🚚 [LOGISTICA] Disparando proceso de envío para la orden: 6a18514aea8181de46097cfe
```

---

## Installation & Setup

### Backend

```bash
cd backend
npm install
cp .env.example .env
```

Configure your `.env`:

```env
PORT=5000
MONGODB_URI=your_mongodb_uri
MERCADOPAGO_ACCESS_TOKEN=your_token
NGROK_BASE_URL=your_ngrok_url
JWT_SECRET=your_secret
```

```bash
npm run dev
```

### Frontend

```bash
cd frontend
flutter pub get
flutter run
```

---

## Roadmap

### Completed
- QR + Card payments
- Webhook reconciliation
- Polling fallback
- Idempotency safeguards
- Distributed checkout consistency

### Planned
- Distributed Idempotency: Migrate memory-based Set to Redis (SETNX) for horizontal scalability.
- Email notifications
- Coupon system
- Multi-tenant support
- Analytics dashboard

---

## About the Developer

**Martín Bernardo Bonilla**  
Fullstack Developer

- GitHub: https://github.com/MartinBernardoBonilla
- LinkedIn: https://www.linkedin.com/in/martinbernardobonilla/
- Portfolio: https://woodstack-portfolio.vercel.app
- Email: martinbernardobonilla@gmail.com

---

## License

MIT © 2026 Martín Bernardo Bonilla
