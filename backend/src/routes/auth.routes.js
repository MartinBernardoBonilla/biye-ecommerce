// routes/auth.routes.js

import express from 'express';
import { body } from 'express-validator';

import {
    loginUser,
    registerUser,
    getUserProfile
} from '../controllers/auth.controller.js';

import validate from '../middleware/validation.middleware.js';
import { protect } from '../middleware/auth.middleware.js';
import User from '../models/user.js';

import {
    generateAccessToken,
    generateRefreshToken,
    verifyToken
} from '../utils/generateToken.js';

const router = express.Router();

// ===============================
// VALIDATIONS
// ===============================
const loginValidation = [
    body('email').isEmail().withMessage('El correo electrónico debe ser válido'),
    body('password').notEmpty().withMessage('La contraseña es obligatoria'),
];

// ===============================
// PUBLIC ROUTES
// ===============================
router.route('/register').post(validate, registerUser);
router.route('/login').post(loginValidation, validate, loginUser);

// ===============================
// REFRESH TOKEN
// ===============================
router.post('/refresh', async (req, res) => {
    try {
        const { refreshToken } = req.body;

        if (!refreshToken) {
            return res.status(401).json({
                success: false,
                message: 'Refresh token requerido',
            });
        }

        const decoded = verifyToken(refreshToken, true);

        if (!decoded) {
            return res.status(401).json({
                success: false,
                message: 'Refresh token inválido o expirado',
            });
        }

        const user = await User.findById(decoded.userId);

        if (!user) {
            return res.status(401).json({
                success: false,
                message: 'Usuario no encontrado',
            });
        }

        const newAccessToken = generateAccessToken(
            user._id,
            user.email,
            user.role
        );

        return res.json({
            success: true,
            data: {
                accessToken: newAccessToken,
            },
        });

    } catch (error) {
        console.error('❌ Error en refresh:', error);

        return res.status(401).json({
            success: false,
            message: 'No se pudo refrescar la sesión',
        });
    }
});

// ===============================
// ADMIN LOGIN (CORREGIDO)
// ===============================
router.route('/admin/login').post(loginValidation, validate, async (req, res) => {
    try {
        const { email, password } = req.body;

        const user = await User.findOne({ email }).select('+password');

        if (!user || !(await user.matchPassword(password))) {
            return res.status(401).json({
                success: false,
                message: 'Credenciales inválidas'
            });
        }

        if (user.role !== 'admin') {
            return res.status(403).json({
                success: false,
                message: 'No tienes permisos de administrador'
            });
        }

        const accessToken = generateAccessToken(
            user._id,
            user.email,
            user.role
        );

        const refreshToken = generateRefreshToken(user._id);

        res.json({
            success: true,
            data: {
                id: user._id,
                name: user.username,
                email: user.email,
                role: user.role,
                accessToken,
                refreshToken,
            },
            message: 'Login de administrador exitoso'
        });

    } catch (error) {
        console.error("Error en login de administrador:", error);
        res.status(500).json({
            success: false,
            message: 'Error en el servidor'
        });
    }
});

// ===============================
// PROTECTED ROUTES
// ===============================
router.route('/me').get(protect, getUserProfile);

export default router;