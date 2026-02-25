// Archivo: src/middleware/admin.middleware.js

// Middleware adminAuth
export const adminAuth = (req, res, next) => {
    // 1. Log de debug para rastrear el rol
    console.log(`[AUTH DEBUG] Verificando rol para: ${req.user ? req.user.role : 'N/A'}`); 
    
    // 2. Comprobar si existe el usuario y si su rol es 'admin' (ignorando capitalización)
    if (req.user && req.user.role && req.user.role.toLowerCase() === 'admin') { 
        // Es administrador, continuar
        next(); 
    } else {
        // No es administrador, denegar acceso
        return res.status(403).json({
            success: false,
            message: 'No autorizado. Se requiere acceso de Administrador.'
        }); 
    }
};