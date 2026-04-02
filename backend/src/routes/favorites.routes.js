import express from 'express';
import { protect } from '../middleware/auth.js';
import {
  getFavorites,
  addFavorite,
  removeFavorite,
  checkFavorite
} from '../controllers/favorites.controller.js';

const router = express.Router();

// Todas las rutas requieren autenticación
router.use(protect);

// GET /api/v1/favorites - Obtener todos los favoritos
// POST /api/v1/favorites - Agregar favorito
router.route('/')
  .get(getFavorites)
  .post(addFavorite);

// DELETE /api/v1/favorites/:productId - Eliminar favorito
// GET /api/v1/favorites/:productId - Verificar si es favorito
router.route('/:productId')
  .delete(removeFavorite)
  .get(checkFavorite);

export default router;
