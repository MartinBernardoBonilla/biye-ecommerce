import mongoose from 'mongoose';

export const connectDB = async () => {
    const MONGO_URI = process.env.MONGODB_URI;

    if (!MONGO_URI) {
        throw new Error('La variable MONGODB_URI no está definida');
    }

    try {
        const conn = await mongoose.connect(MONGO_URI);

        console.log(`✅ MongoDB conectado: ${conn.connection.host}`);
    } catch (error) {
        console.error(`❌ Error de conexión a MongoDB: ${error.message}`);
        throw error;
    }
};
