// routes/auth.routes.js
// Rutas para la autenticación de usuarios (registro y login)

import express from 'express';
// Importamos solo lo necesario para validar y el controlador
import { body } from 'express-validator'; 
import { loginUser, registerUser, getUserProfile } from '../controllers/auth.controller.js';
import validate from '../middleware/validation.middleware.js'; 
import { protect } from '../middleware/auth.middleware.js';
import User from '../models/User.js';
// CORRECCIÓN: Importar como named export
import { generateToken } from '../utils/generateToken.js';

const router = express.Router();

// Validaciones para el login y registro
const loginValidation = [
    body('email').isEmail().withMessage('El correo electrónico debe ser válido'),
    body('password').notEmpty().withMessage('La contraseña es obligatoria'),
];

// --------------------------------------------------------------------------
// 🔓 1. RUTAS PÚBLICAS
// --------------------------------------------------------------------------

// Ruta de Registro y Login (Usuario Estándar)
router.route('/register').post(/* validaciones */ validate, registerUser);
router.route('/login').post(loginValidation, validate, loginUser);

// --------------------------------------------------------------------------
// 🔓 2. RUTA ESPECÍFICA PARA LOGIN DE ADMIN (NO DEBE LLEVAR MIDDLEWARE DE PROTECCIÓN)
// --------------------------------------------------------------------------
router.route('/admin/login').post(loginValidation, validate, async (req, res) => {
    try {
        const { email, password } = req.body;

        const user = await User.findOne({ email }).select('+password');

        // 1. Fallo si no existe o la contraseña no coincide
        if (!user || !(await user.matchPassword(password))) {
            return res.status(401).json({
                success: false,
                message: 'Credenciales inválidas'
            });
        }

        // 2. Fallo si no es administrador
        if (user.role !== 'admin') {
            return res.status(403).json({
                success: false,
                message: 'No tienes permisos de administrador'
            });
        }

        // 3. Éxito: Generar Token y devolver datos del admin
        const token = generateToken(user._id); // ⬅️ Ahora funciona correctamente
        
        res.json({
            success: true,
            data: {
                id: user._id,
                name: user.username,
                email: user.email,
                role: user.role,
                token: token
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

// --------------------------------------------------------------------------
// 🔒 3. RUTAS PROTEGIDAS
// --------------------------------------------------------------------------

// Obtener perfil del usuario logueado
router.route('/profile').get(protect, getUserProfile);

export default router;
