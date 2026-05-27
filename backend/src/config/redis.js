import { createClient } from 'redis';

// Intentamos conectar al Redis real usando la URL del .env
const redisClient = createClient({
  url: process.env.REDIS_URL || 'redis://127.0.0.1:6379'
});

redisClient.on('error', (err) => {
  console.error('❌ [REDIS ERROR]:', err.message);
});

redisClient.on('connect', () => {
  console.log('🛑 [REDIS] Intentando establecer conexión...');
});

redisClient.on('ready', () => {
  console.log('✅ [REDIS] ¡Conectado y listo para usar en DB real!');
});

// Inicializamos la conexión asincrónica
try {
  await redisClient.connect();
} catch (error) {
  console.error('❌ No se pudo conectar a Redis Server. Asegurate de que esté corriendo con "sudo systemctl start redis-server"');
}

export default redisClient;