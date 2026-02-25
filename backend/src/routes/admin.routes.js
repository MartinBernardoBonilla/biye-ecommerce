// src/routes/admin.routes.js
import express from 'express';

// Importar controladores de productos
import { 
    getAdminProducts,
    createProduct, 
    updateProduct, 
    deleteProduct
} from '../controllers/products.controller.js'; 

// Importar controladores de admin
import {
    getAdminStats,
    getRecentOrders,
    getAllOrders,
    getAllUsers
} from '../controllers/admin.controller.js';

// Importar middlewares
import { protect } from '../middleware/auth.middleware.js';
import { adminAuth } from '../middleware/admin.middleware.js';
import { uploadSingleImage } from '../middleware/upload.middleware.js';
import { uploadToCloudinary } from '../middleware/uploadToCloudinary.middleware.js';

const router = express.Router();

// 🔒 Middleware de autenticación con logs
router.use((req, res, next) => {
  console.log('🛡️ [ADMIN ROUTE] Acceso a:', req.method, req.url);
  console.log('🛡️ [ADMIN ROUTE] Headers:', req.headers.authorization ? 'Bearer token presente' : 'Sin token');
  next();
});

// 🔒 TODAS las rutas requieren: 1) estar logueado, 2) ser admin
router.use(protect, adminAuth);

// --- DASHBOARD Y ESTADÍSTICAS ---
router.get('/stats', (req, res, next) => {
  console.log('📊 [ADMIN] Solicitando stats');
  next();
}, getAdminStats);

router.get('/orders/recent', getRecentOrders);
router.get('/orders', getAllOrders);
router.get('/users', getAllUsers);

// --- GESTIÓN DE PRODUCTOS (CRUD Admin) ---
router.get('/products', getAdminProducts);

router.post(
  '/products',
  uploadSingleImage,
  uploadToCloudinary,
  createProduct
);

router.patch(
  '/products/:id', 
  uploadSingleImage,  
  uploadToCloudinary, 
  updateProduct
);

router.delete('/products/:id', deleteProduct);

export default router;