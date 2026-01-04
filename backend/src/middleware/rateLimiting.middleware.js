// src/middleware/rateLimiting.middleware.js
import rateLimit from 'express-rate-limit';

// 🔐 Auth (login / register)
export const authLimiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 100,
    message: 'Demasiadas solicitudes desde esta IP, por favor, inténtalo de nuevo después de 15 minutos.',
});

// 🌍 General API
export const apiLimiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 100,
});
