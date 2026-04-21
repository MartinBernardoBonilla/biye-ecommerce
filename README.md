# Biye — Plataforma de E-commerce Fullstack

[![Flutter](https://img.shields.io/badge/Flutter-3.41-02569B?style=flat&logo=flutter&logoColor=white)](https://flutter.dev)
[![Node.js](https://img.shields.io/badge/Node.js-20-339933?style=flat&logo=node.js&logoColor=white)](https://nodejs.org)
[![MongoDB](https://img.shields.io/badge/MongoDB-8.0-47A248?style=flat&logo=mongodb&logoColor=white)](https://mongodb.com)
[![Mercado Pago](https://img.shields.io/badge/Mercado_Pago-009EE3?style=flat&logo=mercadopago&logoColor=white)](https://mercadopago.com)

Biye es una plataforma de e-commerce fullstack moderna y flexible, pensada para adaptarse fácilmente a distintos tipos de negocio.

Cuenta con un sistema de pagos robusto integrado con Mercado Pago (tanto QR presencial como tarjetas online), incluyendo confirmación en tiempo real mediante webhooks y polling, y está construida sobre una arquitectura limpia y escalable, lista para personalizar y crecer.

---

## ✨ Demo en Vivo

- **Frontend (Web)**: [Ver Demo](https://biye-app.vercel.app)
- **Backend API**: [https://biye-ecommerce-production.up.railway.app](https://biye-ecommerce-production.up.railway.app)

> Proyecto desarrollado con enfoque en robustez de pagos y escalabilidad.

---

## Capturas de Pantalla

*(Próximamente)*

<!-- 
Aquí irán las capturas del flujo completo:
- Pantalla de inicio y productos
- Carrito de compras
- Checkout con selección de dirección y método de pago
- Pantalla de QR / Checkout Pro
- Pantalla de pago exitoso
-->

---

## Características Principales

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

## Tecnologías Utilizadas

**Frontend**  
- Flutter + Dart  
- BLoC + Hydrated BLoC (gestión de estado)  
- `qr_flutter`, `url_launcher`

**Backend**  
- Node.js + Express  
- MongoDB + Mongoose  
- Mercado Pago SDK oficial  
- Redis (cache)  
- JWT + Rate Limiting

**DevOps**  
- Docker + Docker Compose  
- Railway + Vercel  
- Ngrok (desarrollo)

---

## Cómo Ejecutar Localmente

### 1. Clonar el repositorio
```bash
git clone https://github.com/MartinBernardoBonilla/biye-ecommerce.git
cd biye-ecommerce

2. Backendbash

cd backend
npm install
cp .env.example .env          # Configura tus credenciales
npm run dev

3. Frontendbash

cd frontend
flutter pub get
flutter run

Variables de Entorno (Backend)env

PORT=5000
MONGODB_URI=...
MERCADOPAGO_ACCESS_TOKEN=APP_USR-...
NGROK_BASE_URL=https://tu-ngrok.ngrok-free.dev
JWT_SECRET=tu_secret_key

Tarjetas de Prueba (Sandbox)Marca
Número
CVV
Vencimiento
Visa
4509 9535 6623 3704
123
11/25
Mastercard
5031 7557 3453 0604
123
11/25

RoadmapSistema de pagos completo (QR + Tarjeta)
Webhook + Polling + Idempotencia
Dashboard administrativo
Notificaciones por email
Sistema de cupones y descuentos
Soporte multi-negocio / Multi-tenant

AutorMartín Bernardo Bonilla
Fullstack Developer especializado en Flutter y Node.jsLicencia
MIT © 2026 Martín Bernardo Bonilla

