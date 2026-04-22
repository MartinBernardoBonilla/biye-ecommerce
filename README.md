# Biye — Plataforma de E-commerce Fullstack

[![Flutter](https://img.shields.io/badge/Flutter-3.41-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Node.js](https://img.shields.io/badge/Node.js-20-339933?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org)
[![MongoDB](https://img.shields.io/badge/MongoDB-8.0-47A248?style=for-the-badge&logo=mongodb&logoColor=white)](https://mongodb.com)
[![Mercado Pago](https://img.shields.io/badge/Mercado_Pago-009EE3?style=for-the-badge&logo=mercadopago&logoColor=white)](https://mercadopago.com)

Biye es una plataforma de e-commerce fullstack moderna y flexible, pensada para adaptarse fácilmente a distintos tipos de negocio.

Cuenta con un sistema de pagos robusto integrado con Mercado Pago (tanto QR presencial como tarjetas online), incluyendo confirmación en tiempo real mediante webhooks y polling, y está construida sobre una arquitectura limpia y escalable, lista para personalizar y crecer.

---

## ✨ Demo en Vivo

- **Frontend (Web)**: [Ver Demo](https://biye-app.vercel.app)
- **Backend API**: [https://biye-ecommerce-production.up.railway.app](https://biye-ecommerce-production.up.railway.app)

> Proyecto desarrollado con enfoque en robustez de pagos y escalabilidad.

---

## 📸 Capturas de Pantalla

<div align="center">
  
| Pantalla de Inicio | Sección / Favoritos |
|:------------------:|:-------------------:|
| ![Home](https://res.cloudinary.com/dwchpxcrv/image/upload/imagen1_qezswq.jpg) | ![Productos](https://res.cloudinary.com/dwchpxcrv/image/upload/imagen_u19ub1.jpg) |

</div>

> ⚡ Aplicación en funcionamiento - Vista de productos y navegación.

---

## 🚀 Características Principales

- ✅ **Sistema de pagos completo con Mercado Pago**
  - QR para pago presencial
  - Checkout Pro con tarjeta (online)
  - Webhook + Polling inteligente + Fallback automático
  - Idempotencia en pagos
- ✅ Gestión completa de órdenes, direcciones y métodos de pago
- ✅ Autenticación JWT segura
- ✅ Arquitectura limpia (BLoC + Clean Architecture en frontend)
- ✅ Rate limiting y manejo robusto de errores
- ✅ Fácilmente adaptable a diferentes negocios
- ✅ Soporte para modo Sandbox y Producción

---

## 🛠️ Stack Tecnológico 

### Frontend
[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)

### Backend
[![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org)
[![Express](https://img.shields.io/badge/Express-000000?style=for-the-badge&logo=express&logoColor=white)](https://expressjs.com)
[![MongoDB](https://img.shields.io/badge/MongoDB-47A248?style=for-the-badge&logo=mongodb&logoColor=white)](https://mongodb.com)
[![Redis](https://img.shields.io/badge/Redis-DC382D?style=for-the-badge&logo=redis&logoColor=white)](https://redis.io)

### Pagos
[![Mercado Pago](https://img.shields.io/badge/Mercado_Pago-009EE3?style=for-the-badge&logo=mercadopago&logoColor=white)](https://mercadopago.com)

### DevOps
[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://docker.com)
[![Railway](https://img.shields.io/badge/Railway-0B0D0E?style=for-the-badge&logo=railway&logoColor=white)](https://railway.app)
[![Vercel](https://img.shields.io/badge/Vercel-000000?style=for-the-badge&logo=vercel&logoColor=white)](https://vercel.com)

---

## 📦 Cómo Ejecutar Localmente

### 1. Clonar el repositorio

` ` `bash
git clone https://github.com/MartinBernardoBonilla/biye-ecommerce.git
cd biye-ecommerce
` ` `

### 2. Backend

` ` `bash
cd backend
npm install
cp .env.example .env
npm run dev
` ` `

### 3. Frontend

` ` `bash
cd frontend
flutter pub get
flutter run
` ` `

---

## 🔐 Variables de Entorno (Backend)

` ` `env
PORT=5000
MONGODB_URI=tu_url_de_mongodb
MERCADOPAGO_ACCESS_TOKEN=APP_USR-tu_token
NGROK_BASE_URL=https://tu-ngrok.ngrok-free.dev
JWT_SECRET=tu_clave_secreta
` ` `

---

## 💳 Tarjetas de Prueba (Sandbox Mercado Pago)

| Marca | Número | CVV | Vencimiento |
|-------|--------|-----|-------------|
| Visa | 4509 9535 6623 3704 | 123 | 11/25 |
| Mastercard | 5031 7557 3453 0604 | 123 | 11/25 |

---

## 🗺️ Roadmap

- [x] Sistema de pagos completo (QR + Tarjeta)
- [x] Webhook + Polling + Idempotencia
- [x] Dashboard administrativo
- [ ] Notificaciones por email
- [ ] Sistema de cupones y descuentos
- [ ] Soporte multi-negocio / Multi-tenant

---

## 👤 Autor

**Martín Bernardo Bonilla** — Fullstack Developer especializado en Flutter y Node.js

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://linkedin.com/in/martinbernardobonilla)
[![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/MartinBernardoBonilla)
[![Email](https://img.shields.io/badge/Email-D14836?style=for-the-badge&logo=gmail&logoColor=white)](mailto:martinbernardobonilla@gmail.com)

---

## 📄 Licencia

[![MIT License](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

MIT © 2026 Martín Bernardo Bonilla
