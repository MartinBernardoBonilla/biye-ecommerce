import jwt from 'jsonwebtoken';

/**
 * Genera un token JWT para un usuario
 * @param {string} userId - ID del usuario
 * @param {string} email - Email del usuario
 * @param {string} role - Rol del usuario (admin, user, etc.)
 * @returns {string} - Token JWT
 */
export const generateToken = (userId, email, role = 'user') => {
  const payload = {
    userId,
    email,
    role,
    iat: Math.floor(Date.now() / 1000),
  };

  return jwt.sign(
    payload,
    process.env.JWT_SECRET || 'fallback_secret_key',
    {
      expiresIn: process.env.JWT_EXPIRES_IN || '7d',
    }
  );
};

/**
 * Verifica y decodifica un token JWT
 * @param {string} token - Token JWT a verificar
 * @returns {object|null} - Payload decodificado o null si es inválido
 */
export const verifyToken = (token) => {
  try {
    return jwt.verify(
      token,
      process.env.JWT_SECRET || 'fallback_secret_key'
    );
  } catch (error) {
    console.error('Error verifying token:', error.message);
    return null;
  }
};

export default { generateToken, verifyToken };