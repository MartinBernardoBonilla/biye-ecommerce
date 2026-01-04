import mongoose from 'mongoose';

// Usamos el nombre 'MONGODB_URI' para coincidir con la variable en docker-compose.yml
const MONGO_URI = process.env.MONGODB_URI; 

export const connectDB = async () => {
    // ⚠️ Validación de existencia de la URI
    if (!MONGO_URI) {
        console.error('❌ Error CRÍTICO de configuración: La variable MONGODB_URI no está definida.');
        process.exit(1);
    }
    
    try {
        // Conexión a la base de datos. Se han eliminado las opciones deprecated (useNewUrlParser, useUnifiedTopology)
        const conn = await mongoose.connect(MONGO_URI);

        console.log(`✅ MongoDB conectado: ${conn.connection.host} (URI utilizada: ${MONGO_URI})`);
    } catch (error) {
        // Un error común aquí es que el servicio 'mongo' aún no esté listo
        console.error(`❌ Error de conexión a MongoDB: ${error.message}`);
        
        // Retardo para dar tiempo a que la base de datos se levante
        console.log('Intentando de nuevo en 5 segundos...');
        await new Promise(resolve => setTimeout(resolve, 5000));
        
        // El proceso se cerrará si falla repetidamente
        process.exit(1); 
    }
};
