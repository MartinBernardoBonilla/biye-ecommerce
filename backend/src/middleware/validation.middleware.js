// src/middleware/validation.middleware.js

// Importamos validationResult de express-validator para recopilar los errores
import { validationResult } from 'express-validator';

/**
 * Middleware para procesar los resultados de express-validator.
 * Si hay errores de validación, detiene el flujo y devuelve una respuesta 400.
 * Si no hay errores, llama a next() para continuar con el controlador de la ruta.
 */
const validate = (req, res, next) => {
    // Recopila los errores de validación que se han acumulado en la petición
    const errors = validationResult(req);

    if (errors.isEmpty()) {
        // Si la lista de errores está vacía, la validación fue exitosa.
        return next(); 
    }

    // Si hay errores, formatearlos y enviar una respuesta 400 (Bad Request)
    return res.status(400).json({
        success: false,
        message: 'Error de validación de datos',
        errors: errors.array().map(error => ({
            field: error.path, // 'param' en versiones antiguas
            message: error.msg
        }))
    });
};

export default validate;