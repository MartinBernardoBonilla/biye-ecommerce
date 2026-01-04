// src/routes/coupons.routes.js
import { Router } from 'express';
import {
    getCoupons,
    createCoupon,
    deleteCoupon,
} from '../controllers/coupons.controller.js';

import { protect, admin } from '../middleware/auth.middleware.js';

const router = Router();

// Admin only
router.use(protect, admin);

router.get('/', getCoupons);
router.post('/', createCoupon);
router.delete('/:id', deleteCoupon);

export default router;
