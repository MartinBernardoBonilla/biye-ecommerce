# Biye — E-commerce Platform

[![Flutter](https://img.shields.io/badge/Flutter-3.22-02569B?style=flat&logo=flutter&logoColor=white)](https://flutter.dev)
[![Node.js](https://img.shields.io/badge/Node.js-20-339933?style=flat&logo=node.js&logoColor=white)](https://nodejs.org)
[![MongoDB](https://img.shields.io/badge/MongoDB-7.0-47A248?style=flat&logo=mongodb&logoColor=white)](https://mongodb.com)
[![MercadoPago](https://img.shields.io/badge/MercadoPago-API-009EE3?style=flat)](https://mercadopago.com)

App de e-commerce fullstack con sistema de pagos completo: QR presencial,
tarjeta online y confirmación en tiempo real mediante webhooks y polling.

---

## Características

| Feature | Estado |
|---|---|
| Pagos con QR (presencial) | ✅ |
| Pagos con tarjeta vía Checkout Pro | ✅ |
| Webhook + Polling + Fallback automático | ✅ |
| Idempotencia en webhook | ✅ |
| QR real generado como base64 | ✅ |
| Modo Sandbox / Producción | ✅ |
| Autenticación JWT | ✅ |
| Rate limiting | ✅ |

---

## Arquitectura

```
Flutter App  ──▶  Node.js API  ──▶  MercadoPago
     ▲                │
     │                ▼
  BLoC State      MongoDB
```

**Flujo de pago:**
1. Usuario confirma orden
2. Backend crea preferencia en MercadoPago
3. Se genera QR o link de pago según método elegido
4. Webhook recibe notificación → validación de idempotencia
5. Polling como fallback si el webhook no llega
6. UI actualiza estado y limpia carrito

---

## Tecnologías

**Frontend (Flutter)**
- BLoC para manejo de estado
- `qr_flutter` para renderizado de QR
- `url_launcher` para Checkout Pro

**Backend (Node.js)**
- Express + Mongoose
- MercadoPago SDK oficial
- `qrcode` para generación de QR
- `express-rate-limit` para seguridad

---

## Instalación local

### 1. Clonar el repositorio
```bash
git clone https://github.com/MartinBernardoBonilla/biye-ecommerce.git
cd biye-ecommerce
```

### 2. Backend
```bash
cd backend
npm install
cp .env.example .env   # completar con tus credenciales
npm run dev
```

### 3. Frontend
```bash
cd frontend
flutter pub get
flutter run
```

---

## Variables de entorno

```env
PORT=5000
BACK_URL=https://tu-ngrok.ngrok-free.dev
MONGODB_URI=mongodb+srv://...
MERCADOPAGO_ACCESS_TOKEN=TEST-xxx
MP_MODE=sandbox
JWT_SECRET=tu_secret
```

---

## Tarjetas de prueba (Sandbox)

| Marca | Número | CVV | Vencimiento |
|---|---|---|---|
| Visa | 4509 9535 6623 3704 | 123 | 11/25 |
| Mastercard | 5031 7557 3453 0604 | 123 | 11/25 |

---

## Roadmap

- [x] Sistema de pagos completo
- [x] QR real (base64)
- [x] Webhook + Polling + Fallback
- [ ] Dashboard administrativo
- [ ] Email de confirmación de compra
- [ ] Sistema de cupones

---

## Licencia

MIT © Martín Bernardo Bonilla
