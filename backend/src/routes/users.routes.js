import { Router } from 'express';
import {
    registerUser,
    loginUser,
    getMe,
    updateUser,
    deleteUser,
    getAllUsers
} from '../controllers/users.controller.js';
import { protect, admin } from '../middleware/auth.middleware.js';

const router = Router();

// Públicas
router.post('/register', registerUser);
router.post('/login', loginUser);

// Privadas
router.get('/me', protect, getMe);

// Admin
router.get('/', protect, admin, getAllUsers);
router.put('/:id', protect, admin, updateUser);
router.delete('/:id', protect, admin, deleteUser);

export default router;
