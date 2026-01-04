// controllers/auth.controller.js
import User from '../models/User.js'; // CRÍTICO: Usar import y añadir .js
import asyncHandler from '../middleware/asyncHandler.middleware.js'; // CRÍTICO: Usar import y añadir .js
import jwt from 'jsonwebtoken';

// Función auxiliar para generar el JWT
const generateToken = (id) => {
    // Usamos el secreto del .env que se cargó en app.js
    return jwt.sign({ id }, process.env.JWT_SECRET, {
        expiresIn: '30d' // El token expira en 30 días
    });
};

// @desc    Registrar un nuevo usuario
// @route   POST /api/v1/auth/register
// @access  Public
export const registerUser = asyncHandler(async (req, res) => { // CRÍTICO: Usar export const
    const { username, email, password } = req.body;

    const userExists = await User.findOne({ email });

    if (userExists) {
        // En lugar de devolver un JSON, lanzamos un error que asyncHandler manejará.
        res.status(400);
        throw new Error('El usuario ya existe con este correo.');
    }

    // Se crea el usuario (la contraseña se hashea automáticamente con el middleware 'pre' del modelo)
    const user = await User.create({
        username,
        email,
        password,
    });

    if (user) {
        // Devolvemos la información del usuario y el token
        res.status(201).json({
            success: true,
            data: {
                _id: user._id,
                username: user.username,
                email: user.email,
                role: user.role,
                token: generateToken(user._id),
            }
        });
    } else {
        res.status(400);
        throw new Error('Datos de usuario no válidos.');
    }
});

// @desc    Autenticar usuario y obtener token
// @route   POST /api/v1/auth/login
// @access  Public
export const loginUser = asyncHandler(async (req, res) => { // CRÍTICO: Usar export const
    const { email, password } = req.body;

    // Buscar el usuario, seleccionando explícitamente la contraseña
    const user = await User.findOne({ email }).select('+password');

    // Verificar si el usuario existe y si la contraseña coincide
    if (user && (await user.matchPassword(password))) {
        // Si es válido, devolvemos la información y un nuevo token
        res.json({
            success: true,
            data: {
                _id: user._id,
                username: user.username,
                email: user.email,
                role: user.role,
                token: generateToken(user._id),
            }
        });
    } else {
        res.status(401);
        throw new Error('Email o contraseña incorrectos.');
    }
});

// @desc    Obtener perfil del usuario (protegida)
// @route   GET /api/v1/auth/profile
// @access  Private
export const getUserProfile = asyncHandler(async (req, res) => { // CRÍTICO: Usar export const
    // req.user es inyectado por el middleware 'auth'
    const user = await User.findById(req.user.id); 

    if (user) {
        res.json({
            success: true,
            data: {
                _id: user._id,
                username: user.username,
                email: user.email,
                role: user.role,
            }
        });
    } else {
        res.status(404);
        throw new Error('Usuario no encontrado.');
    }
});
