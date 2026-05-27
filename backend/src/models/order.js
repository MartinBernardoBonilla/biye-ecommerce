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
        required: false,
    },

    items: {
        type: [ItemSchema],
        required: true,
        validate: {
            validator: function (v) {
                return v && v.length > 0;
            },
            message: 'Un pedido debe contener al menos un artículo.'
        }
    },

    itemsPrice: {
        type: Number,
        required: true,
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

    paymentStatus: {
        type: String,
        default: 'pending',
        enum: ['pending', 'approved', 'rejected', 'refunded']
    },

    isPaid: {
        type: Boolean,
        default: false
    },

    buyerInfo: {
        email: { type: String, required: true },
        name: { type: String },
        phone: { type: String }
    },

    paidAt: {
        type: Date,
        default: null
    },

    // 🚚 SUB-ESQUEMA DE LOGÍSTICA Y ENVÍOS INTEGRADO
    shipping: {
        method: {
            type: String,
            enum: ['pickup', 'custom_moto', 'carrier'],
            required: true,
            default: 'pickup'
        },
        carrierName: { type: String, default: null }, // 'andreani', 'local_moto', etc.
        serviceType: { type: String, default: null }, // 'sucursal', 'domicilio'
        cost: { type: Number, required: true, default: 0 },

        address: {
            street: { type: String, required: function () { return this.shipping.method !== 'pickup'; } },
            number: { type: String, required: function () { return this.shipping.method !== 'pickup'; } },
            floor: { type: String, default: null },
            apartment: { type: String, default: null },
            city: { type: String, required: function () { return this.shipping.method !== 'pickup'; } },
            province: { type: String, required: function () { return this.shipping.method !== 'pickup'; } },
            zipCode: { type: String, required: function () { return this.shipping.method !== 'pickup'; } },
        },

        tracking: {
            trackingNumber: { type: String, default: null },
            status: {
                type: String,
                enum: ['pending_label', 'ready_to_ship', 'in_transit', 'delivered', 'failed'],
                default: 'pending_label'
            },
            labelUrl: { type: String, default: null },
            estimatedDelivery: { type: Date, default: null }
        }
    }

}, {
    timestamps: true
});

const Order = mongoose.model('Order', OrderSchema);

// Usamos exportación por defecto.
export default Order;