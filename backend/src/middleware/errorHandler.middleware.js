// src/middleware/errorHandler.middleware.js

const errorHandler = (err, req, res, next) => {
    console.error(`[API ERROR] ${req.method} ${req.originalUrl}`);
    console.error(err);

    let statusCode = err.statusCode || res.statusCode || 500;
    let message = err.message || 'Error interno del servidor';
    let errors = {};

    // 🟢 VALIDACIONES DE MONGOOSE
    if (err.name === 'ValidationError') {
        statusCode = 400;
        message = 'Error de validación';
        Object.keys(err.errors).forEach(key => {
            errors[key] = err.errors[key].message;
        });
    }

    // 🟢 ERROR DE ÍNDICE ÚNICO (unique: true)
    if (err.code === 11000) {
        statusCode = 400;
        const campo = Object.keys(err.keyValue)[0];
        message = `Ya existe un registro con ese ${campo}`;
    }

    // 🟢 JSON MAL FORMADO
    if (err.type === 'entity.parse.failed') {
        statusCode = 400;
        message = 'El cuerpo de la solicitud no es JSON válido';
    }

    res.status(statusCode).json({
        success: false,
        message,
        ...(Object.keys(errors).length > 0 && { errors }),
        // stack: process.env.NODE_ENV === 'development' ? err.stack : undefined
    });
};

export default errorHandler;
