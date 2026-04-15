import express from 'express';
import { protect } from '../middleware/auth.middleware.js';
import {
  getAddresses,
  getAddressById,
  createAddress,
  updateAddress,
  deleteAddress,
  setDefaultAddress
} from '../controllers/address.controller.js';

const router = express.Router();

// Todas las rutas requieren autenticación
router.use(protect);

// Rutas principales
router.route('/')
  .get(getAddresses)
  .post(createAddress);

// Ruta para establecer dirección default
router.put('/default/:id', setDefaultAddress);

// Rutas para dirección específica
router.route('/:id')
  .get(getAddressById)
  .put(updateAddress)
  .delete(deleteAddress);

export default router;