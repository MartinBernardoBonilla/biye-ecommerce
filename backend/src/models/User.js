import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';// ⬅️ CAMBIADO A 'bcrypt'

// Si instalaste 'bcryptjs', déjalo como estaba: import bcrypt from 'bcryptjs';

// 1. Define el esquema del usuario
const UserSchema = new mongoose.Schema({
    username: {
        type: String,
        required: [true, 'El nombre de usuario es requerido'],
        unique: true,
        trim: true
    },
    email: {
        type: String,
        required: [true, 'El correo electrónico es requerido'],
        unique: true,
        match: [
            /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/,
            'Por favor, añade un correo electrónico válido'
        ]
    },
    // CRÍTICO: Asegurarse de que `select: false` esté aquí para que no se devuelva la contraseña por defecto
    password: { 
        type: String,
        required: [true, 'La contraseña es requerida'],
        minlength: 6,
        select: false 
    },
    role: {
        type: String,
        enum: ['user', 'admin'],
        default: 'user'
    }
}, {
    timestamps: true
});

// 2. Middleware para hashear la contraseña antes de guardar
UserSchema.pre('save', async function(next) {
    // Solo hashear si el campo de contraseña ha sido modificado (o es nuevo)
    if (!this.isModified('password')) {
        next();
    }

    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
});

// 3. Método para comparar la contraseña ingresada con la hasheada
UserSchema.methods.matchPassword = async function(enteredPassword) {
    // 🔥 CORRECCIÓN: Necesitamos obtener la contraseña primero
    const user = await this.model('User').findById(this._id).select('+password');
    return await bcrypt.compare(enteredPassword, user.password);
};

// 4. Exportación por defecto para usar con `import User from ...`
const User = mongoose.model('User', UserSchema);

export default User;