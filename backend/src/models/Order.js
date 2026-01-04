import mongoose from 'mongoose';

// Definición del esquema para un solo artículo dentro del pedido
const ItemSchema = new mongoose.Schema({
    productId: { 
        type: mongoose.Schema.Types.ObjectId,
        required: true,
        ref: 'Product' 
    },
    name: {
        type: String,
        required: true
    },
    quantity: {
        type: Number,
        required: true,
        min: 1
    },
    unitPrice: {
        type: Number,
        required: true,
        min: 0
    },
    imageUrl: {
        type: String,
        default: ''
    }
}, { _id: false }); 

// Definición del esquema principal de la Orden
const OrderSchema = new mongoose.Schema({
    user: { 
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: false 
    },
    
    items: {
        type: [ItemSchema],
        required: true,
        validate: {
            validator: function(v) {
                return v && v.length > 0;
            },
            message: 'Un pedido debe contener al menos un artículo.'
        }
    },
    
    totalAmount: {
        type: Number,
        required: true,
        min: 0.01
    },

    currency: {
        type: String,
        required: true,
        uppercase: true,
        trim: true,
        enum: ['ARS', 'USD', 'BRL'] 
    },
    
    status: {
        type: String,
        required: true,
        default: 'PENDING', 
        enum: ['PENDING', 'WAITING_PAYMENT', 'PAID', 'CANCELLED', 'SHIPPED', 'DELIVERED']
    },
    
    paymentDetails: {
        type: {
            paymentId: { type: String }, 
            preferenceId: { type: String }, 
            method: { type: String },
            statusDetail: { type: String },
        },
        required: false 
    },

    buyerInfo: {
        email: { type: String, required: true },
        name: { type: String },
        phone: { type: String }
    },

    paidAt: {
        type: Date,
        default: null
    }

}, {
    timestamps: true 
});

const Order = mongoose.model('Order', OrderSchema);

// Usamos exportación por defecto.
export default Order;
