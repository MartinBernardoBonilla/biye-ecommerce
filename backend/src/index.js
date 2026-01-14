import './config/env.js'; // 🔥 PRIMERA LÍNEA REAL

import app from './app.js';
import { connectDB } from './config/database.js';
import redisClient from './config/redis.js';

const PORT = process.env.PORT || 5000;

// logs ahora sí
console.log('=== 🚀 INICIANDO SERVIDOR BIYE ===');
console.log('MONGODB_URI:', !!process.env.MONGODB_URI);
console.log('JWT_SECRET:', !!process.env.JWT_SECRET);
console.log('MP TOKEN:', !!process.env.MERCADOPAGO_ACCESS_TOKEN);

// Rutas
import paymentsRoutes from './routes/payments.routes.js';


// 🔗 Registrar rutas ANTES de listen
app.use('/api/v1/payments', paymentsRoutes);

(async () => {
  try {
    console.log('🔗 Conectando a MongoDB...');
    await connectDB();
    console.log('✅ MongoDB conectado');

    try {
      await redisClient.connect();
      console.log('✅ Redis conectado y listo');
    } catch (redisError) {
      console.warn('⚠️ Redis no disponible, continuando sin cache');
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
