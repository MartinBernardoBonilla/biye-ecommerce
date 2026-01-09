import cloudinary from '../config/cloudinary.js';

export const uploadToCloudinary = async (req, res, next) => {
  // Si no hay archivo, seguimos (producto sin imagen)
  if (!req.file) {
    return next();
  }

  try {
    const stream = cloudinary.uploader.upload_stream(
      {
        folder: 'biye/products',
        resource_type: 'image',
      },
      (error, result) => {
        if (error) {
          return next(error);
        }

        // Dejamos la imagen lista para el controller
        req.cloudinaryImage = {
          url: result.secure_url,
          public_id: result.public_id,
        };

        next();
      }
    );

    stream.end(req.file.buffer);

  } catch (error) {
    next(error);
  }
};
