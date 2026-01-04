// src/middleware/upload.middleware.js

// Usamos import/export para ser coherentes con ES Modules
import multer from 'multer'; 

// 1. Configuración de almacenamiento en memoria (RAM)
// Esto evita la escritura en disco y es ideal para subir directamente a Cloudinary.
const storage = multer.memoryStorage();

const upload = multer({ 
    storage: storage,
    // Opcional: Límite de 5MB para la imagen
    limits: { fileSize: 5 * 1024 * 1024 }, 
    // Opcional: Filtro para asegurar que solo suban imágenes
    fileFilter: (req, file, cb) => {
        if (file.mimetype.startsWith('image')) {
            cb(null, true);
        } else {
            cb(new Error('Solo se permiten archivos de imagen.'), false);
        }
    }
});

// 🟢 CORRECCIÓN CLAVE: Usamos 'export const' para una exportación con nombre
// 'image' es el nombre del campo que el frontend de Flutter envía.
// En backend/src/middleware/upload.middleware.js
export const uploadSingleImage = (req, res, next) => {
  // 🟢 NUEVO: Si es web y viene imageUrl, procesar de manera diferente
  if (req.body && req.body.imageUrl && req.body.imageUrl.includes('cloudinary')) {
    console.log('🌐 Middleware: Detected imageUrl from web, skipping file upload');
    // Establecemos req.file como null para que updateProduct sepa que no hay archivo
    req.file = null;
    return next();
  }
  
  // 🟢 EXISTENTE: Para móvil/desktop, usar multer normalmente
  upload.single('image')(req, res, (err) => {
    if (err) {
      console.error('❌ Error en multer:', err.message);
      return res.status(400).json({
        success: false,
        message: err.message
      });
    }
    next();
  });
};