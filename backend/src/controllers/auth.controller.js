// controllers/auth.controller.js

import User from '../models/user.js';
import asyncHandler from '../middleware/asyncHandler.middleware.js';

import {
    generateAccessToken,
    generateRefreshToken,
} from '../utils/generateToken.js';

// ===============================
// REGISTER
// ===============================
export const registerUser = asyncHandler(async (req, res) => {
    const { username, email, password } = req.body;

    const userExists = await User.findOne({ email });

    if (userExists) {
        res.status(400);
        throw new Error('El usuario ya existe con este correo.');
    }

    const user = await User.create({
        username,
        email,
        password,
    });

    if (user) {
        const accessToken = generateAccessToken(
            user._id,
            user.email,
            user.role
        );

        const refreshToken = generateRefreshToken(user._id);

        res.status(201).json({
            success: true,
            data: {
                _id: user._id,
                username: user.username,
                email: user.email,
                role: user.role,
                token: accessToken,        // 🔥 UNIFICADO
                refreshToken: refreshToken // 🔥 NUEVO
            },
        });
    } else {
        res.status(400);
        throw new Error('Datos de usuario no válidos.');
    }
});

// ===============================
// LOGIN
// ===============================
export const loginUser = asyncHandler(async (req, res) => {
    const { email, password } = req.body;

    const user = await User.findOne({ email }).select('+password');

    if (user && (await user.matchPassword(password))) {

        const accessToken = generateAccessToken(
            user._id,
            user.email,
            user.role
        );

        const refreshToken = generateRefreshToken(user._id);

        res.json({
            success: true,
            data: {
                _id: user._id,
                username: user.username,
                email: user.email,
                role: user.role,
                token: accessToken,        // 🔥 MISMO FORMATO
                refreshToken: refreshToken // 🔥 NUEVO
            }
        });

    } else {
        res.status(401);
        throw new Error('Email o contraseña incorrectos.');
    }
});

// ===============================
// PROFILE
// ===============================
export const getUserProfile = asyncHandler(async (req, res) => {
    const user = await User.findById(req.user.userId);

    if (user) {
        res.json({
            success: true,
            data: {
                _id: user._id,
                username: user.username,
                email: user.email,
                role: user.role,
            },
        });
    } else {
        res.status(404);
        throw new Error('Usuario no encontrado.');
    }
});