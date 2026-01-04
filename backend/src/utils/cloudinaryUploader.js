import { v2 as cloudinary } from 'cloudinary';
import streamifier from 'streamifier';

// Configuración de Cloudinary
// NOTA: Estas son credenciales diferentes a las del frontend
// El frontend usa upload preset, el backend usa API key/secret

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME || 'dwchpxcrv',
  api_key: process.env.CLOUDINARY_API_KEY || 'tu_api_key_backend',
  api_secret: process.env.CLOUDINARY_API_SECRET || 'tu_api_secret_backend',
});

/**
 * Sube una imagen a Cloudinary desde un buffer
 * @param {Buffer} fileBuffer - Buffer de la imagen
 * @param {Object} options - Opciones adicionales
 * @returns {Promise<Object>} - Resultado de la subida
 */
export const uploadToCloudinary = async (fileBuffer, options = {}) => {
  return new Promise((resolve, reject) => {
    const uploadStream = cloudinary.uploader.upload_stream(
      {
        folder: 'biye/products',
        resource_type: 'auto',
        ...options,
      },
      (error, result) => {
        if (error) {
          console.error('Error subiendo a Cloudinary:', error);
          reject(error);
        } else {
          resolve({
            url: result.secure_url,
            publicId: result.public_id,
            format: result.format,
            width: result.width,
            height: result.height,
            bytes: result.bytes,
          });
        }
      }
    );

    streamifier.createReadStream(fileBuffer).pipe(uploadStream);
  });
};

/**
 * Elimina una imagen de Cloudinary
 * @param {string} publicId - ID público de la imagen
 * @returns {Promise<Object>} - Resultado de la eliminación
 */
export const deleteFromCloudinary = async (publicId) => {
  try {
    const result = await cloudinary.uploader.destroy(publicId);
    return result;
  } catch (error) {
    console.error('Error eliminando de Cloudinary:', error);
    throw error;
  }
};

/**
 * Genera URL optimizada para una imagen
 * @param {string} publicId - ID público de la imagen
 * @param {Object} transformations - Transformaciones de Cloudinary
 * @returns {string} - URL optimizada
 */
export const getOptimizedImageUrl = (publicId, transformations = {}) => {
  const defaultTransformations = {
    width: 800,
    height: 600,
    crop: 'fill',
    quality: 'auto',
    format: 'webp',
  };

  return cloudinary.url(publicId, {
    ...defaultTransformations,
    ...transformations,
  });
};

// Para compatibilidad con imports existentes
export default {
  uploadToCloudinary,
  deleteFromCloudinary,
  getOptimizedImageUrl,
};