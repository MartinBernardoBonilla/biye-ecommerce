<div align="center">

# 🛒 **BIYE** <sub><sub>v1.0</sub></sub>

### Production-Oriented Fullstack Mobile E-Commerce Platform

[![Flutter](https://img.shields.io/badge/Flutter-3.41-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Node.js](https://img.shields.io/badge/Node.js-20-339933?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org)
[![MongoDB](https://img.shields.io/badge/MongoDB-8.0-47A248?style=for-the-badge&logo=mongodb&logoColor=white)](https://mongodb.com)
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

## Technical Challenges Solved

Biye handles real-world edge cases such as:

- Delayed webhook delivery
- Duplicate callback events
- Interrupted checkout sessions
- Pending payment reconciliation
- Frontend/backend state desynchronization

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

[![Tests](https://img.shields.io/badge/tests-19_passing-brightgreen?style=for-the-badge)]()

| Type | Count | Coverage |
|------|------:|---------|
| Unit Tests | 17 | Cart logic, validation, pricing rules |
| Widget Tests | 2 | Core UI rendering |

Run tests:

```bash
cd frontend
flutter test
```

---

## Installation

### Clone Repository

```bash
git clone https://github.com/MartinBernardoBonilla/biye-ecommerce.git
cd biye-ecommerce
```

### Backend Setup

```bash
cd backend
npm install
cp .env.example .env
```

Configure:

```env
PORT=5000
MONGODB_URI=your_mongodb_uri
MERCADOPAGO_ACCESS_TOKEN=your_token
NGROK_BASE_URL=your_ngrok_url
JWT_SECRET=your_secret
```

Run:

```bash
npm run dev
```

---

### Frontend Setup

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
- Admin dashboard
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
