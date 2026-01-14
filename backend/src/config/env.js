import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// ⬅️ subimos dos niveles hasta /biye/.env
dotenv.config({
  path: path.resolve(__dirname, '../../.env'),
});

console.log('✅ ENV CARGADO:', {
  NODE_ENV: process.env.NODE_ENV,
  MONGO: !!process.env.MONGODB_URI,
  JWT: !!process.env.JWT_SECRET,
  MP: !!process.env.MERCADOPAGO_ACCESS_TOKEN,
});
