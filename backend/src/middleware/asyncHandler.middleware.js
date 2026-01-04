/**
 * src/middleware/asyncHandler.middleware.js
 * Función wrapper que maneja errores de controladores asíncronos.
 * Esto evita la necesidad de escribir bloques try...catch en cada función async/await
 * y pasa cualquier excepción automáticamente al middleware de manejo de errores (errorHandler).
 * * @param {Function} fn - El controlador asíncrono de Express (req, res, next).
 * @returns {Function} - Una función que ejecuta el controlador y captura cualquier error.
 */
const asyncHandler = fn => (req, res, next) => {
    // Promise.resolve().catch(next) asegura que cualquier error capturado dentro 
    // de la función fn (que es asíncrona) sea pasado a la cadena de middleware de Express.
    Promise.resolve(fn(req, res, next)).catch(next);
};

// CRÍTICO: Exportar usando ES Modules (export default)
export default asyncHandler;
