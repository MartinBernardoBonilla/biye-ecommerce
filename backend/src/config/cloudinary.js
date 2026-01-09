// src/config/cloudinary.js

import { v2 as cloudinary } from 'cloudinary';
// No necesitas importar dotenv si ya lo haces con el comando de inicio

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
  secure: true, // Siempre usar HTTPS
});

console.log('☁️ Cloudinary ENV CHECK:', {
  cloud: process.env.CLOUDINARY_CLOUD_NAME,
  key: process.env.CLOUDINARY_API_KEY,
  secret: process.env.CLOUDINARY_API_SECRET ? 'OK' : 'MISSING',
});


// 🟢 EXPORTACIÓN POR DEFECTO (Necesario para 'import cloudinary from ...')
export default cloudinary;