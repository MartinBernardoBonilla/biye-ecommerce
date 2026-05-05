<div align="center">
  
# 🛒 **BIYE** <sub><sub>v1.0</sub></sub>

### *Plataforma de E-commerce Fullstack* ⚡

[![Flutter](https://img.shields.io/badge/Flutter-3.41-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Node.js](https://img.shields.io/badge/Node.js-20-339933?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org)
[![MongoDB](https://img.shields.io/badge/MongoDB-8.0-47A248?style=for-the-badge&logo=mongodb&logoColor=white)](https://mongodb.com)
[![Mercado Pago](https://img.shields.io/badge/Mercado_Pago-009EE3?style=for-the-badge&logo=mercadopago&logoColor=white)](https://mercadopago.com)

</div>

---

Biye es una plataforma de e-commerce fullstack moderna y flexible, pensada para adaptarse fácilmente a distintos tipos de negocio. 

Cuenta con un sistema de pagos robusto integrado con Mercado Pago (tanto QR presencial como tarjetas online), incluyendo confirmación en tiempo real mediante webhooks y polling, y está construida sobre una arquitectura limpia y escalable.

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
- **Flutter & Dart**

### Backend
- **Node.js, Express, MongoDB & Redis**

### DevOps & Deploy
- **Docker, Railway & Vercel**

---

## 🧪 Tests

[![Tests](https://img.shields.io/badge/tests-19_passing-brightgreen?style=for-the-badge)](https://github.com/MartinBernardoBonilla/biye-ecommerce/tree/main/frontend/test)

El proyecto incluye **19 tests** que garantizan la estabilidad del sistema:

| Tipo | Cantidad | Qué prueba |
|------|----------|------------|
| Unit tests | 17 | Cálculo de carrito, validación de email/teléfono, descuentos |
| Widget tests | 2 | Renderizado básico de componentes |

Para correr los tests:

```bash
cd frontend
flutter test
```
```
📦 Cómo Ejecutar Localmente
```
1. Clonar el repositorio
```
bash
git clone https://github.com/MartinBernardoBonilla/biye-ecommerce.git
cd biye-ecommerce
```
2. Configuración del Backend0
```
bash
cd backend
npm install
cp .env.example .env
# Edita el archivo .env con tus credenciales
npm run dev
```
3. Configuración del Frontend
```
bash
cd frontend
flutter pub get
flutter run
```
🔐 Variables de Entorno (Backend)
```
env
PORT=5000
MONGODB_URI=tu_url_de_mongodb
MERCADOPAGO_ACCESS_TOKEN=APP_USR-tu_token
NGROK_BASE_URL=https://tu-ngrok.ngrok-free.dev
JWT_SECRET=tu_clave_secreta
```
🗺️ Roadmap
Sistema de pagos completo (QR + Tarjeta)

Webhook + Polling + Idempotencia

Dashboard administrativo

Notificaciones por email

Sistema de cupones y descuentos

Soporte multi-negocio / Multi-tenant

📫 Contacto
https://img.shields.io/badge/LinkedIn-Mart%C3%ADn_Bonilla-0077B5?style=for-the-badge&logo=linkedin&logoColor=white
https://img.shields.io/badge/GitHub-MartinBernardoBonilla-181717?style=for-the-badge&logo=github&logoColor=white
https://img.shields.io/badge/Email-martinbernardobonilla%2540gmail.com-D14836?style=for-the-badge&logo=gmail&logoColor=white
https://img.shields.io/badge/Portfolio-WoodStack-646CFF?style=for-the-badge&logo=vite&logoColor=white

📌 Disponibilidad: 100% remoto · Primera experiencia laboral o proyectos freelance

👤 Autor
Martín Bernardo Bonilla — Fullstack Developer

📄 Licencia
MIT © 2026 Martín Bernardo Bonilla
