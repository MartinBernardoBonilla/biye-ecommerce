# 🛍️ Biye — Plataforma E-Commerce Integral con Pagos Mercado Pago

**Biye** es una solución moderna y escalable para e-commerce, desarrollada en **Node.js + Express** con integración a **MongoDB, Redis** y **Mercado Pago**.  
Pensada para ofrecer una experiencia completa de venta, compra y gestión administrativa, adaptable tanto a pequeñas tiendas como a grandes catálogos.

---

## 🚀 Características Principales

✅ **Arquitectura modular y escalable** con Express y ES Modules.  
✅ **Base de datos MongoDB** para gestión eficiente de usuarios, productos y pedidos.  
✅ **Redis** para cacheo, optimización y sesiones seguras.  
✅ **Pasarela de pago Mercado Pago** completamente integrada (creación de preferencias, feedback y webhook).  
✅ **Panel administrativo seguro** (en desarrollo).  
✅ **Autenticación JWT** con roles de usuario y administrador.  
✅ **Integración lista para frontends en Flutter, React o Next.js.**  
✅ **Contenedorización completa con Docker Compose.**  
✅ **Logs detallados y middleware de errores personalizado.**

---

## 🧠 Stack Tecnológico

| Categoría | Tecnología |
|------------|-------------|
| **Backend** | Node.js (v22), Express, ES Modules |
| **Base de datos** | MongoDB (v6) |
| **Cache y sesiones** | Redis (v7) |
| **Pagos** | Mercado Pago SDK oficial |
| **Contenedores** | Docker, Docker Compose |
| **Logs y Debug** | Morgan, Winston (opcional) |
| **Autenticación** | JSON Web Token (JWT) |
| **Despliegue** | AWS / Render / Railway / GCP |
| **Frontend compatible** | Flutter, React, Next.js |

---

## ⚙️ Instalación y Uso Local

```bash
# 1️⃣ Clonar el repositorio
git clone https://github.com/tuusuario/biye.git
cd biye/backend

# 2️⃣ Crear el archivo .env
cp .env.example .env

# 3️⃣ Levantar los contenedores
sudo docker compose up -d --build

# 4️⃣ Ver logs del backend
sudo docker logs -f backend-backend-1

# 5️⃣ Probar el endpoint principal
curl http://localhost:5000
```

---

## 🔗 Endpoints Principales

| Ruta | Método | Descripción |
|------|---------|-------------|
| `/api/v1/products` | GET | Listado de productos |
| `/api/v1/auth/register` | POST | Registro de usuarios |
| `/api/v1/orders` | POST | Crear orden |
| `/api/v1/payments/preference` | POST | Crear preferencia de pago |
| `/api/v1/payments/feedback` | GET | Resultado de pago |
| `/api/v1/payments/mercadopago-webhook` | POST | Webhook para Mercado Pago |

---

## 🌱 Mejoras Futuras

📲 App para repartidores (con GPS en tiempo real)  
🔔 Sistema de notificaciones push (Firebase Cloud Messaging)  
🧮 Panel analítico con métricas de ventas, productos y clientes  
💬 Chat en vivo entre comprador y vendedor  
🧾 Facturación automática con PDF y envío por correo  
☁️ Despliegue en la nube (AWS, Render, Railway o GCP)

---

## 🤝 Asistencia y Soporte Continuo

El proyecto está preparado para mantenimiento y soporte técnico permanente:

- Actualizaciones de dependencias  
- Monitoreo de logs y resolución de errores  
- Configuración de webhooks y túneles seguros (ngrok)  
- Documentación de despliegue y CI/CD  
- Asesoramiento para mejoras e integración de nuevos módulos  

---

## 👨‍💻 Autor

**Martín Bonilla**  
Desarrollador Full Stack  
📍 Argentina  
💬 Enfocado en soluciones escalables, limpias y optimizadas para comercio electrónico.  
📧 martinbonilla.dev@example.com  
🌐 [linkedin.com/in/martinbonilla](https://linkedin.com/in/martinbonilla)
# Biye
