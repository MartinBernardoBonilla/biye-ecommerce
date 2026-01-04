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

const app = express();

// ⭐⭐ CORS CONFIGURACIÓN CORRECTA PARA ES MODULES ⭐⭐
// En tu src/app.js, actualiza corsOptions:
const corsOptions = {
    origin: function (origin, callback) {
        // Permitir todo en desarrollo (TEMPORAL)
        if (process.env.NODE_ENV !== 'production') {
            return callback(null, true);
        }
        
        const allowedOrigins = [
            'http://localhost:42321',
            'http://localhost:3000', 
            'http://localhost:5000',
            'http://127.0.0.1:42321',
            'http://127.0.0.1:3000',
            'http://127.0.0.1:5000',
            'https://biye-web.com', // tu dominio futuro
        ];
        
        if (!origin || allowedOrigins.includes(origin) || 
            origin.includes('localhost') || 
            origin.includes('127.0.0.1')) {
            callback(null, true);
        } else {
            callback(new Error('No permitido por CORS'));
        }
    },
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS', 'PATCH'],
    allowedHeaders: ['Content-Type', 'Authorization', 'Accept', 'Origin', 'X-Requested-With'],
    exposedHeaders: ['Content-Range', 'X-Content-Range'],
    maxAge: 86400, // 24 horas
};

app.use(cors(corsOptions));
app.options('*', cors(corsOptions));



app.use(express.json({ limit: '10mb' }));


if (process.env.NODE_ENV === 'development') {
    app.use(morgan('dev'));
    console.log('🚀 Servidor Biye - ES Modules activado');
}

// Mercado Pago
const accessToken = process.env.MERCADOPAGO_ACCESS_TOKEN;
if (!accessToken) {
    console.error('⚠️  MERCADOPAGO_ACCESS_TOKEN no configurado');
} else {
    const mpClient = new MercadoPagoConfig({
        accessToken,
        options: { timeout: 5000 },
    });
    app.locals.paymentClient = mpClient;

    console.log('✅ Mercado Pago configurado');
}

// Rutas
app.use('/api/v1', authRoutes);
app.use('/api/v1/admin', adminRoutes);
app.use('/api/v1/products', productRoutes);
app.use('/api/v1/payments', paymentRoutes);
app.use('/api/v1/categories', categoriesRoutes);



// Health checks
app.get('/', (req, res) => {
    res.json({ 
        message: '✅ Servidor Biye ES Modules',
        environment: process.env.NODE_ENV || 'development',
        cors: 'configurado',
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
        timestamp: new Date().toISOString()
    });
});

app.use(errorHandler);

export default app;


