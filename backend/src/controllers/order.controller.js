// Asumo que asyncHandler está en src/middleware o src/utils, ajusta la ruta si es necesario.
import asyncHandler from '../middleware/asyncHandler.middleware.js'; 
import Order from '../models/Order.js'; 
// Importa cualquier otro modelo necesario (e.g., Producto o Usuario si es requerido)

// @desc    Obtener todas las órdenes del usuario autenticado
// @route   GET /api/v1/orders/myorders
// @access  Private (Usuario)
export const getMyOrders = asyncHandler(async (req, res) => {
    // Buscar órdenes donde el campo 'user' coincida con el ID del usuario autenticado (req.user._id)
    const orders = await Order.find({ user: req.user._id }).sort({ createdAt: -1 });

    if (orders) {
        res.status(200).json(orders);
    } else {
        res.status(404);
        throw new Error('No se encontraron órdenes para este usuario.');
    }
});

// @desc    Obtener detalles de una orden por ID
// @route   GET /api/v1/orders/:id
// @access  Private (Usuario)
export const getOrderById = asyncHandler(async (req, res) => {
    // Buscar la orden por ID, asegurando que sea del usuario correcto.
    const order = await Order.findById(req.params.id);

    if (order && order.user.toString() === req.user._id.toString()) {
        res.status(200).json(order);
    } else {
        res.status(404);
        throw new Error('Orden no encontrada o no pertenece a este usuario.');
    }
});


// @desc    Obtener todas las órdenes (solo para Administradores)
// @route   GET /api/v1/orders
// @access  Private/Admin
export const getAllOrders = asyncHandler(async (req, res) => {
    // Implementación simple: obtener todas las órdenes.
    // Usamos .populate('user', 'id name') para incluir el nombre del usuario.
    const orders = await Order.find({}).populate('user', 'id name').sort({ createdAt: -1 });
    
    res.status(200).json(orders);
});

// Nota: Puedes añadir aquí otras funciones de controlador (e.g., addOrderItems, updateOrderToPaid)
