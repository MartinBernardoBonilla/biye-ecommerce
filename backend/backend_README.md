# ⚙️ Backend — Biye

Este backend corresponde al sistema **Biye**, una plataforma de e-commerce desarrollada en **Node.js + Express**, con base de datos **MongoDB**, cache con **Redis**, y pagos integrados con **Mercado Pago**.

---

## 🚀 Stack

- Node.js 22 (ES Modules)
- Express
- MongoDB 6
- Redis 7
- Mercado Pago SDK oficial
- Docker + Docker Compose
- JWT para autenticación
- Morgan para logs

---

## 🧩 Estructura Base

```
backend/
├── src/
│   ├── config/
│   ├── controllers/
│   ├── middleware/
│   ├── models/
│   ├── routes/
│   └── utils/
├── Dockerfile
├── docker-compose.yml
├── package.json
└── .env.example
```

---

## ⚙️ Configuración Rápida

```bash
# Clonar el proyecto
git clone https://github.com/tuusuario/biye.git
cd biye/backend

# Crear archivo .env
cp .env.example .env

# Levantar servicios
sudo docker compose up -d --build

# Revisar logs
sudo docker logs -f backend-backend-1
```

---

## 🔗 Endpoints Clave

| Ruta | Método | Descripción |
|------|---------|-------------|
| `/api/v1/products` | GET | Listado de productos |
| `/api/v1/orders` | POST | Crear orden |
| `/api/v1/payments/preference` | POST | Crear preferencia de pago |
| `/api/v1/payments/mercadopago-webhook` | POST | Webhook de Mercado Pago |

---

## 🌱 Próximas Mejoras

- Integración con Firebase Cloud Messaging (notificaciones push)
- Chat interno entre compradores y vendedores
- Panel de métricas de ventas y productos
- Facturación automática (PDF)
- App para repartidores con GPS

---

## 🧑‍💻 Mantenimiento

Proyecto mantenido por **Martín Bonilla**  
Actualizaciones, soporte y mejoras continuas.
