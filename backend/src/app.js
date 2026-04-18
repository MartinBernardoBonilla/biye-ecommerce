import express from 'express';
import cors from 'cors';
import morgan from 'morgan';
import { MercadoPagoConfig } from 'mercadopago';
import productRoutes from './routes/products.routes.js';
import paymentRoutes from './routes/payments.routes.js';
import errorHandler from './middleware/errorHandler.middleware.js';
import adminRoutes from './routes/admin.routes.js';
import authRoutes from './routes/auth.routes.js';
import categoriesRoutes from './routes/categories.routes.js';
import ordersRoutes from './routes/orders.routes.js';
import favoritesRoutes from './routes/favorites.routes.js';
import addressRoutes from './routes/address.routes.js';
import paymentMethodsRoutes from './routes/paymentMethods.routes.js';


const app = express();

// ⭐⭐ CORS CONFIGURACIÓN ÚNICA Y CORRECTA ⭐⭐
const corsOptions = {
  origin: function (origin, callback) {
    // En desarrollo, permitir TODO (incluye Ngrok, localhost, etc.)
    if (process.env.NODE_ENV !== 'production') {
      return callback(null, true);
    }

    // En producción, whitelist específica
    const allowedOrigins = [
      process.env.FRONTEND_URL,
      'https://biye-app.vercel.app',
      'https://biye-web.com',
      'http://localhost:42321',
      'http://localhost:3000',
    ].filter(Boolean);

    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('No permitido por CORS'));
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS', 'PATCH'],
  allowedHeaders: [
    'Content-Type',
    'Authorization',
    'Accept',
    'Origin',
    'X-Requested-With',
    'ngrok-skip-browser-warning' // 👈 AGREGADO PARA NGROK
  ],
  exposedHeaders: ['Content-Range', 'X-Content-Range'],
  maxAge: 86400,
};

// Aplicar CORS UNA SOLA VEZ (eliminé la segunda configuración)
app.use(cors(corsOptions));

// Manejar preflight requests (OPTIONS)
app.options('*', cors(corsOptions));

app.use(express.json({ limit: '10mb' }));

// Morgan SOLO en desarrollo (así el import NO se pone gris)
if (process.env.NODE_ENV === 'development') {
  app.use(morgan('dev')); // 👈 MORGAN SE USA AQUÍ
  console.log('🚀 Servidor Biye - ES Modules activado');
  console.log('📝 Logging HTTP con morgan activado');
}

// Mercado Pago
const accessToken = process.env.MERCADOPAGO_ACCESS_TOKEN;

if (!accessToken) {
  console.error('⚠️ MERCADOPAGO_ACCESS_TOKEN no configurado');
} else {
  console.log(
    '💳 MP MODE:',
    accessToken.startsWith('TEST-') ? 'TEST' : 'PROD'
  );

  const mpClient = new MercadoPagoConfig({
    accessToken,
    options: { timeout: 5000 },
  });

  app.locals.paymentClient = mpClient;
  console.log('✅ Mercado Pago configurado');
}

// Rutas
app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/admin', adminRoutes);
app.use('/api/v1/products', productRoutes);
app.use('/api/v1/payments', paymentRoutes);
app.use('/api/v1/categories', categoriesRoutes);
app.use('/api/v1/orders', ordersRoutes);
app.use('/api/v1/favorites', favoritesRoutes);
app.use('/api/v1/addresses', addressRoutes);
app.use('/api/v1/payment-methods', paymentMethodsRoutes);


// Health checks
app.get('/', (req, res) => {
  res.json({
    message: '✅ Servidor Biye ES Modules',
    environment: process.env.NODE_ENV || 'development',
    cors: 'configurado',
    morgan: process.env.NODE_ENV === 'development' ? 'activo' : 'inactivo',
    timestamp: new Date().toISOString()
  });
});

app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    modules: 'ES Modules',
    timestamp: new Date().toISOString()
  });
});

app.get('/test-cors', (req, res) => {
  res.json({
    message: '✅ CORS funcionando',
    origin: req.headers.origin || 'none',
    ngrok_header: req.headers['ngrok-skip-browser-warning'] ? 'presente' : 'ausente',
    timestamp: new Date().toISOString()
  });
});

app.use(errorHandler);

export default app;