// src/middleware/auth.middleware.js

import jwt from 'jsonwebtoken';
import asyncHandler from './asyncHandler.middleware.js';
import User from '../models/User.js'; 

export const protect = asyncHandler(async (req, res, next) => {
    let token;

    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
        try {
            token = req.headers.authorization.split(' ')[1];

            const decoded = jwt.verify(token, process.env.JWT_SECRET);

            console.log(
                '💚 [PROTECT DEBUG] Token decodificado. ID:',
                decoded.user.id
            );

            req.user = await User
                .findById(decoded.user.id)
                .select('-password');

            if (!req.user) {
                res.status(401);
                throw new Error('Usuario no encontrado o eliminado');
            }

            console.log(`💚 [PROTECT DEBUG] Usuario: ${req.user.email}`);
            next();

        } catch (error) {
            console.error('❌ Error en protect:', error.message);
            res.status(401);
            throw new Error('No autorizado, token inválido');
        }
    } else {
        res.status(401);
        throw new Error('No autorizado, no se encontró token');
    }
});

export const admin = (req, res, next) => {
    if (req.user && req.user.isAdmin) {
        next();
    } else {
        res.status(403);
        throw new Error('No autorizado, requiere rol admin');
    }
};
