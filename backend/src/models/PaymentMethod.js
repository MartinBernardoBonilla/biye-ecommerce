import mongoose from 'mongoose';

const paymentMethodSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  type: {
    type: String,
    enum: ['card', 'mercadopago', 'other'],
    required: true
  },
  // Para tarjetas de crédito/débito
  cardDetails: {
    lastFourDigits: String,
    brand: String, // visa, mastercard, etc.
    expirationMonth: String,
    expirationYear: String,
    cardholderName: String
  },
  // Para MercadoPago
  mpPaymentMethodId: String,
  mpPaymentTypeId: String,
  // Campos comunes
  isDefault: {
    type: Boolean,
    default: false
  },
  isActive: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true
});

// Índice compuesto
paymentMethodSchema.index({ user: 1, isDefault: 1 });

// Middleware: asegurar que solo un método es default por usuario
paymentMethodSchema.pre('save', async function(next) {
  if (this.isDefault) {
    await this.constructor.updateMany(
      { user: this.user, _id: { $ne: this._id } },
      { isDefault: false }
    );
  }
  next();
});

const PaymentMethod = mongoose.model('PaymentMethod', paymentMethodSchema);
export default PaymentMethod;