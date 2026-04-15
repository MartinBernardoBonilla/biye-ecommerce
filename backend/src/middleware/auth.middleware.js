import jwt from 'jsonwebtoken';
import User from '../models/user.js';

/**
 * Middleware para proteger rutas que requieren autenticación
 */
export const protect = async (req, res, next) => {
  let token;

  // Verificar si el token está en el header Authorization
  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    token = req.headers.authorization.split(' ')[1];
  }

  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'No autorizado, no se proporcionó token'
    });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Obtener el usuario (soportar tanto decoded.id como decoded.userId)
    const userId = decoded.userId || decoded.id;
    req.user = await User.findById(userId).select('-password');

    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: 'Usuario no encontrado'
      });
    }

    next();
  } catch (error) {
    console.error('❌ Auth error:', error.message);
    return res.status(401).json({
      success: false,
      message: 'No autorizado, token inválido'
    });
  }
};

/**
 * Middleware para verificar si es administrador
 */
export const admin = (req, res, next) => {
  if (req.user && req.user.role === 'admin') {
    next();
  } else {
    return res.status(403).json({
      success: false,
      message: 'Acceso denegado. Se requieren permisos de administrador'
    });
  }
};
