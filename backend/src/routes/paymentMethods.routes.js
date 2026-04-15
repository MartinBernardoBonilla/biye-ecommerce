import express from 'express';
import { protect } from '../middleware/auth.middleware.js';
import {
  getPaymentMethods,
  getPaymentMethodById,
  addCard,
  deletePaymentMethod,
  setDefaultPaymentMethod
} from '../controllers/paymentMethod.controller.js';

const router = express.Router();

router.use(protect);

router.route('/')
  .get(getPaymentMethods)
  .post(addCard);

router.put('/default/:id', setDefaultPaymentMethod);

router.route('/:id')
  .get(getPaymentMethodById)
  .delete(deletePaymentMethod);

export default router;