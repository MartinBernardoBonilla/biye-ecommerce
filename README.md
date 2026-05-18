<div align="center">

# 🛒 **BIYE** <sub><sub>v1.0</sub></sub>

### Production-Oriented Fullstack Mobile E-Commerce Platform

[![Flutter](https://img.shields.io/badge/Flutter-3.41-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Node.js](https://img.shields.io/badge/Node.js-20-339933?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org)
[![MongoDB](https://img.shields.io/badge/MongoDB-8.0-47A248?style=for-the-badge&logo=mongodb&logoColor=white)](https://mongodb.com)
[![Mercado Pago](https://img.shields.io/badge/Mercado_Pago-009EE3?style=for-the-badge&logoColor=white)](https://mercadopago.com)

**Resilient payment processing · Event-driven order reconciliation · Distributed state consistency**

</div>

---

## Overview

**Biye** is a production-oriented fullstack mobile e-commerce platform built to explore real-world distributed payment challenges.

Beyond standard shopping features, the project focuses on **fault-tolerant checkout orchestration**, combining webhook-driven payment confirmation, polling-based reconciliation, idempotent order processing, and eventual consistency guarantees.

The system was designed to address reliability issues commonly found in asynchronous payment workflows such as:

- Delayed payment confirmations
- Duplicate webhook notifications
- Temporary provider inconsistencies
- Interrupted client sessions during checkout

---

## Live Demo

- **Frontend (Web):**  
  https://biye-app-final.vercel.app

- **Backend API:**  
  https://biye-ecommerce-production.up.railway.app

---

## Engineering Focus

Biye explores core distributed systems concepts applied to e-commerce payment infrastructure:

- **Event-driven payment confirmation**
- **Fallback reconciliation strategies**
- **Idempotent transaction processing**
- **Eventual consistency**
- **State conflict resolution**
- **Fault-tolerant checkout flows**

---

## Screenshots

<div align="center">

| Home | Products / Favorites |
|:---:|:---:|
| ![Home](https://res.cloudinary.com/dwchpxcrv/image/upload/imagen1_qezswq.jpg) | ![Products](https://res.cloudinary.com/dwchpxcrv/image/upload/imagen_u19ub1.jpg) |

</div>

---

## Core Features

### Payment Infrastructure
- Mercado Pago QR payments
- Online card checkout
- Webhook-first payment confirmation
- Polling reconciliation fallback
- Idempotent payment event processing
- Sandbox and production support

### Commerce Features
- Product catalog
- Shopping cart
- Favorites
- Checkout flow
- Order management
- Address management
- Payment method selection

### Security & Reliability
- JWT authentication
- Session persistence
- Rate limiting
- Defensive error handling
- Robust async state synchronization

### Frontend Architecture
- Flutter + Dart
- BLoC state management
- Clean Architecture
- Modular feature-based structure

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
     │       └── Webhook Notifications
     │
     └── Polling Reconciliation Service
```

---

## Distributed Payment Consistency Design

### 1. Webhook-First Confirmation

Mercado Pago notifies payment events asynchronously.

The backend processes incoming events and updates order state accordingly.

---

### 2. Polling-Based Reconciliation

If webhook delivery is delayed or fails:

- The client periodically requests payment status
- The backend queries Mercado Pago directly
- Order state is reconciled automatically

---

### 3. Idempotent Event Processing

Duplicate payment notifications are safely ignored using unique payment identifiers.

This guarantees that repeated provider events do not create duplicated order transitions.

---

### 4. Eventual Consistency

The payment provider is treated as the source of truth.

Database state converges toward provider-confirmed state through reconciliation.

---

### 5. Conflict Resolution Strategy

Order states follow deterministic precedence:

```text
pending < processing < paid < failed
```

The most advanced valid provider state always prevails.

---

## Technical Challenges Solved

Biye addresses real-world payment edge cases such as:

- Delayed webhook delivery
- Duplicate provider callbacks
- Checkout interruption during payment confirmation
- Pending states that require reconciliation
- State desynchronization between frontend and backend

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

### Infrastructure / Deployment
- Docker
- Railway
- Vercel

### Payment Provider
- Mercado Pago API

---

## Automated Testing

[![Tests](https://img.shields.io/badge/tests-19_passing-brightgreen?style=for-the-badge)]()

Biye includes automated validation across business logic and UI behavior.

| Type | Count | Coverage |
|------|------:|---------|
| Unit Tests | 17 | Cart logic, validation, pricing rules |
| Widget Tests | 2 | Core UI rendering and interactions |

### Run Tests

```bash
cd frontend
flutter test
```

---

## Demo Video

### Full Purchase Flow

https://github.com/MartinBernardoBonilla/biye-ecommerce/raw/main/assets/output_final.mp4

---

## Installation

### Clone Repository

```bash
git clone https://github.com/MartinBernardoBonilla/biye-ecommerce.git
cd biye-ecommerce
```

---

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
- Payment infrastructure
- QR + Card checkout
- Webhook reconciliation
- Polling fallback
- Idempotency safeguards

### Planned
- Admin dashboard
- Email notifications
- Coupon system
- Multi-tenant business support
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
