// src/middleware/auth.middleware.js

import jwt from 'jsonwebtoken';
import asyncHandler from './asyncHandler.middleware.js';
import User from '../models/User.js'; 

export const protect = asyncHandler(async (req, res, next) => {
  let token;

  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith('Bearer')
  ) {
    token = req.headers.authorization.split(' ')[1];
  }

  if (!token) {
    res.status(401);
    throw new Error('No autorizado, no se encontró token');
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

   console.log(
  '💚 [PROTECT DEBUG] Token decodificado. id:',
  decoded.id
);

req.user = await User.findById(decoded.id).select('-password');


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
});


export const admin = (req, res, next) => {
  if (req.user && req.user.role === 'admin') {
    next();
  } else {
    res.status(403);
    throw new Error('No autorizado, requiere rol admin');
  }
};
