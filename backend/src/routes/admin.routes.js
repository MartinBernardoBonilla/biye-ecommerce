// src/routes/admin.routes.js (VERSIÓN CORREGIDA)

import express from 'express';
// Importamos los controladores de CRUD que faltan:
import { 
    getAdminProducts,
    createProduct, 
    updateProduct, 
    deleteProduct // ⬅️ IMPORTACIÓN CRUCIAL
} from '../controllers/products.controller.js'; 

import { protect } from '../middleware/auth.middleware.js';
import { adminAuth } from '../middleware/admin.middleware.js'; 
import { uploadSingleImage } from '../middleware/upload.middleware.js'; // Necesario para POST/PUT
import { uploadToCloudinary } from '../middleware/uploadToCloudinary.middleware.js';

const router = express.Router();

// 🔒 TODAS las rutas requieren: 1) estar logueado, 2) ser admin
router.use(protect, adminAuth);

// --- GESTIÓN DE PRODUCTOS (CRUD Admin) ---

// @route   GET /api/v1/admin/products
router.get('/products', getAdminProducts);

// @route   POST /api/v1/admin/products (Creación)
router.post(
  '/products',
  uploadSingleImage,
  uploadToCloudinary,
  createProduct
);

// @route   PATCH /api/v1/admin/products/:id (Actualización)
// 🎯 CORRECCIÓN CLAVE: Cambiar PUT por PATCH
router.patch('/products/:id', uploadSingleImage,  uploadToCloudinary, updateProduct);
// @route   DELETE /api/v1/admin/products/:id (Eliminación)
router.delete('/products/:id', deleteProduct); // ⬅️ ¡ESTA ES LA RUTA QUE FALTABA!

// ... otras rutas (Dashboard, Users) ...

export default router;