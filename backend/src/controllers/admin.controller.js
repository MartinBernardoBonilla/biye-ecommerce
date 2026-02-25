// backend/src/controllers/admin.controller.js
import Order from '../models/Order.js';
import Product from '../models/Product.model.js';
import User from '../models/User.js';
import asyncHandler from '../middleware/asyncHandler.middleware.js';

/**
 * @desc    Obtener estadísticas del dashboard
 * @route   GET /api/v1/admin/stats
 * @access  Private/Admin
 */
// backend/src/controllers/admin.controller.js

export const getAdminStats = asyncHandler(async (req, res) => {
  // Ejecutar todas las consultas en paralelo para mejor performance
  const [
    totalProducts,
    lowStockCount,
    outOfStockCount,
    activeProducts,
    totalOrders,
    pendingOrders,
    totalUsers
  ] = await Promise.all([
    // Total de productos
    Product.countDocuments(),
    
    // Stock bajo (productos con stock entre 1 y 10)
    Product.countDocuments({ 
      countInStock: { $gt: 0, $lt: 10 }  // 👈 CORREGIDO
    }),
    
    // Sin stock (productos con stock 0)
    Product.countDocuments({ 
      countInStock: 0  // 👈 CORREGIDO
    }),
    
    // Productos activos
    Product.countDocuments({ 
      isActive: true  // 👈 CORREGIDO
    }),
    
    // Total de órdenes
    Order.countDocuments(),
    
    // Órdenes pendientes
    Order.countDocuments({ 
      status: 'WAITING_PAYMENT' 
    }),
    
    // Total de usuarios
    User.countDocuments(),
  ]);

  // Obtener las últimas 5 órdenes para mostrar en el dashboard
  const recentOrders = await Order.find()
    .sort({ createdAt: -1 })
    .limit(5)
    .lean();

  // Formatear órdenes para la respuesta
  const formattedOrders = recentOrders.map(order => ({
    _id: order._id,
    totalAmount: order.totalAmount,
    status: order.status,
    createdAt: order.createdAt,
    items: order.items.map(item => ({
      productId: item.productId,
      name: item.name,
      quantity: item.quantity,
      unitPrice: item.unitPrice
    })),
    buyerInfo: order.buyerInfo
  }));

  res.json({
    success: true,
    data: {
      totalProducts,
      lowStockCount,      // 👈 AHORA DEBERÍA TENER EL VALOR CORRECTO
      outOfStockCount,    // 👈 AHORA DEBERÍA TENER EL VALOR CORRECTO
      activeProducts,     // 👈 AHORA DEBERÍA TENER EL VALOR CORRECTO
      totalOrders,
      pendingOrders,
      totalUsers,
      recentOrders: formattedOrders
    }
  });
});

/**
 * @desc    Obtener órdenes recientes (para dashboard)
 * @route   GET /api/v1/admin/orders/recent
 * @access  Private/Admin
 */
export const getRecentOrders = asyncHandler(async (req, res) => {
  const { limit = 5 } = req.query;

  const orders = await Order.find()
    .sort({ createdAt: -1 })
    .limit(parseInt(limit))
    .populate('items.productId', 'name imageUrl')
    .lean();

  res.json({
    success: true,
    data: orders
  });
});

/**
 * @desc    Obtener todas las órdenes (con paginación)
 * @route   GET /api/v1/admin/orders
 * @access  Private/Admin
 */
export const getAllOrders = asyncHandler(async (req, res) => {
  const { page = 1, limit = 20, status } = req.query;

  const query = {};
  if (status) query.status = status;

  const orders = await Order.find(query)
    .sort({ createdAt: -1 })
    .limit(parseInt(limit))
    .skip((parseInt(page) - 1) * parseInt(limit))
    .populate('items.productId', 'name imageUrl')
    .lean();

  const total = await Order.countDocuments(query);

  res.json({
    success: true,
    data: orders,
    pagination: {
      page: parseInt(page),
      limit: parseInt(limit),
      total,
      pages: Math.ceil(total / parseInt(limit))
    }
  });
});

/**
 * @desc    Obtener todos los usuarios (con paginación)
 * @route   GET /api/v1/admin/users
 * @access  Private/Admin
 */
export const getAllUsers = asyncHandler(async (req, res) => {
  const { page = 1, limit = 20 } = req.query;

  const users = await User.find()
    .sort({ createdAt: -1 })
    .limit(parseInt(limit))
    .skip((parseInt(page) - 1) * parseInt(limit))
    .select('-password') // No enviar la contraseña
    .lean();

  const total = await User.countDocuments();

  res.json({
    success: true,
    data: users,
    pagination: {
      page: parseInt(page),
      limit: parseInt(limit),
      total,
      pages: Math.ceil(total / parseInt(limit))
    }
  });
});

/**
 * @desc    Actualizar rol de usuario
 * @route   PATCH /api/v1/admin/users/:id/role
 * @access  Private/Admin
 */
export const updateUserRole = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const { role } = req.body;

  if (!['user', 'admin'].includes(role)) {
    return res.status(400).json({
      success: false,
      message: 'Rol inválido. Debe ser "user" o "admin"'
    });
  }

  const user = await User.findByIdAndUpdate(
    id,
    { role },
    { new: true }
  ).select('-password');

  if (!user) {
    return res.status(404).json({
      success: false,
      message: 'Usuario no encontrado'
    });
  }

  res.json({
    success: true,
    data: user
  });
});