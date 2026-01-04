// src/routes/categories.routes.js
import express from 'express';

import {
  createCategory,
  getCategories,
  updateCategory,
  deleteCategory
} from '../controllers/categories.controller.js';

import { protect, admin } from '../middleware/auth.middleware.js';

const router = express.Router();

// =======================
// RUTAS PÚBLICAS
// =======================
router.get('/', getCategories);

// =======================
// RUTAS ADMIN
// =======================
router.post('/', protect, admin, createCategory);
router.put('/:id', protect, admin, updateCategory);
router.delete('/:id', protect, admin, deleteCategory);

export default router;
