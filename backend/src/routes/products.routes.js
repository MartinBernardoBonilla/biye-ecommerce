// src/routes/products.routes.js

import { Router } from 'express';
import {
  getProducts,
  getProductById,
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

// Obtener un producto por ID
// GET /api/v1/products/:id
router.get('/:id', getProductById);

export default router;
