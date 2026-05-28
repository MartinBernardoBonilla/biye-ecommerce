import './config/env.js';

import app from './app.js';
import { connectDB } from './config/database.js';
import redisClient from './config/redis.js';

const PORT = process.env.PORT || 5000;

// 🔥 IMPORTAR RUTAS
import paymentsRoutes from './routes/payments.routes.js';
import userRoutes from './routes/users.routes.js';
import authRoutes from './routes/auth.routes.js';
import orderRoutes from './routes/orders.routes.js';
import productRoutes from './routes/products.routes.js';
import categoryRoutes from './routes/categories.routes.js';

// logs
console.log('=== 🚀 INICIANDO SERVIDOR BIYE ===');
console.log('MONGODB_URI:', !!process.env.MONGODB_URI);
console.log('JWT_SECRET:', !!process.env.JWT_SECRET);
console.log('MP TOKEN:', !!process.env.MERCADOPAGO_ACCESS_TOKEN);

// 🔥 REGISTRAR TODAS LAS RUTAS
app.use('/api/v1/payments', paymentsRoutes);
app.use('/api/v1/users', userRoutes);
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/orders', orderRoutes);
app.use('/api/v1/products', productRoutes);
app.use('/api/v1/categories', categoryRoutes);

(async () => {
  try {
    console.log('🔗 Conectando a MongoDB...');
    await connectDB();
    console.log('✅ MongoDB conectado');

    // 🧠 Validamos si el cliente de Redis que se importó ya está conectado de forma real
    if (redisClient.isOpen) {
      console.log('✅ Sistema de Caché e Idempotencia (Redis) activo globalmente');
    } else {
      console.warn('⚠️ Redis no disponible en este hilo, continuando sin caché');
    }

    app.listen(PORT, '0.0.0.0', () => {
      console.log('========================================');
      console.log('🎉 SERVIDOR BIYE ACTIVO');
      console.log('📍 Puerto:', PORT);
      console.log('🌐 URL: http://localhost:' + PORT);
      console.log('⚙️ Entorno:', process.env.NODE_ENV || 'development');
      console.log('========================================');
    });

  } catch (error) {
    console.error('❌ Error crítico al iniciar:', error.message);
    process.exit(1);
  }
})();