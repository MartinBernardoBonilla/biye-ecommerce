import jwt from 'jsonwebtoken';

/**
 * Genera un token JWT para un usuario
 * @param {string} userId - ID del usuario
 * @param {string} email - Email del usuario
 * @param {string} role - Rol del usuario (admin, user, etc.)
 * @returns {string} - Token JWT
 */
// ===============================
// ACCESS TOKEN (tu actual)
// ===============================
export const generateAccessToken = (userId, email, role = 'user') => {
  const payload = {
    userId,
    email,
    role,
    iat: Math.floor(Date.now() / 1000),
  };

  return jwt.sign(
    payload,
    process.env.JWT_SECRET,
    {
      expiresIn: '15m', // 🔥 antes 7d → ahora corto
    }
  );
};

// ===============================
// REFRESH TOKEN (nuevo)
// ===============================
export const generateRefreshToken = (userId) => {
  return jwt.sign(
    { userId },
    process.env.JWT_REFRESH_SECRET,
    {
      expiresIn: '7d',
    }
  );
};

// ===============================
// COMPATIBILIDAD (IMPORTANTE)
// ===============================
export const generateToken = generateAccessToken;

/**
 * Verifica y decodifica un token JWT
 * @param {string} token - Token JWT a verificar
 * @returns {object|null} - Payload decodificado o null si es inválido
 */
// ===============================
// VERIFY
// ===============================
export const verifyToken = (token, isRefresh = false) => {
  try {
    return jwt.verify(
      token,
      isRefresh
        ? process.env.JWT_REFRESH_SECRET
        : process.env.JWT_SECRET
    );
  } catch (error) {
    console.error('Error verifying token:', error.message);
    return null;
  }
};

export default {
  generateAccessToken,
  generateRefreshToken,
  verifyToken,
};