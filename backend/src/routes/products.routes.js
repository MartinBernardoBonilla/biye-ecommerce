// src/routes/products.routes.js

import { Router } from 'express';
import {
  getProducts,
  getProductById,
  getProductCategories,
  getFeaturedProducts,
} from '../controllers/products.controller.js';

const router = Router();

/**
 * ==========================
 * RUTAS PÚBLICAS – PRODUCTS
 * ==========================
 * Base: /api/v1/products
 */

// Obtener todos los productos
// GET /api/v1/products
router.get('/', getProducts);

// Obtener categorías únicas
// GET /api/v1/products/categories
router.get('/categories', getProductCategories);

// GET /api/v1/products/featured
router.get('/featured', getFeaturedProducts);


// Obtener un producto por ID
// GET /api/v1/products/:id
router.get('/:id', getProductById);

export default router;
