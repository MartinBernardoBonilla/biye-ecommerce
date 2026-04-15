import mongoose from 'mongoose';

const addressSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  alias: {
    type: String,
    required: [true, 'El alias es requerido'],
    trim: true,
    maxlength: [50, 'El alias no puede tener más de 50 caracteres']
  },
  recipientName: {
    type: String,
    required: [true, 'El nombre del destinatario es requerido'],
    trim: true
  },
  phone: {
    type: String,
    required: [true, 'El teléfono es requerido'],
    trim: true
  },
  street: {
    type: String,
    required: [true, 'La calle es requerida'],
    trim: true
  },
  number: {
    type: String,
    required: [true, 'El número es requerido'],
    trim: true
  },
  apartment: {
    type: String,
    trim: true,
    default: ''
  },
  city: {
    type: String,
    required: [true, 'La ciudad es requerida'],
    trim: true
  },
  state: {
    type: String,
    required: [true, 'La provincia/estado es requerida'],
    trim: true
  },
  postalCode: {
    type: String,
    required: [true, 'El código postal es requerido'],
    trim: true
  },
  country: {
    type: String,
    required: [true, 'El país es requerido'],
    default: 'Argentina',
    trim: true
  },
  isDefault: {
    type: Boolean,
    default: false
  },
  instructions: {
    type: String,
    trim: true,
    maxlength: [200, 'Las instrucciones no pueden tener más de 200 caracteres']
  }
}, {
  timestamps: true
});

// Índice compuesto para evitar alias duplicados por usuario
addressSchema.index({ user: 1, alias: 1 }, { unique: true });

// Middleware: asegurar que solo una dirección es default por usuario
addressSchema.pre('save', async function(next) {
  if (this.isDefault) {
    await this.constructor.updateMany(
      { user: this.user, _id: { $ne: this._id } },
      { isDefault: false }
    );
  }
  next();
});

const Address = mongoose.model('Address', addressSchema);
export default Address;