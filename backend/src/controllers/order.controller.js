import asyncHandler from '../middleware/asyncHandler.middleware.js';
import Order from '../models/order.js';
import Product from '../models/product.model.js';
import mongoose from 'mongoose';



export const createOrder = asyncHandler(async (req, res) => {
  const { items, buyerInfo, currency } = req.body;

  console.log('Items recibidos para crear orden:', req.body.items);
  // Validaciones básicas
  if (!items || items.length === 0) {
    res.status(400);
    throw new Error('El pedido no contiene artículos');
  }

  if (!buyerInfo || !buyerInfo.email) {
    res.status(400);
    throw new Error('buyerInfo.email es obligatorio');
  }

  // Traer productos reales
  const products = await Product.find({
    _id: { $in: items.map(i => i.productId) },
  });

  let itemsPrice = 0;
  let totalAmount = 0;

  const orderItems = items.map(item => {
    const product = products.find(
      p => p._id.toString() === item.productId
    );

    if (!product) {
      throw new Error('Producto inválido en el pedido');
    }

    const lineTotal = product.price * item.quantity;

    itemsPrice += lineTotal;
    totalAmount += lineTotal;

    return {
      productId: product._id,
      name: product.name,
      quantity: item.quantity,
      unitPrice: product.price,
      imageUrl: product.image?.url || '',
    };
  });

  const order = await Order.create({
    user: req.user?._id || null,
    items: orderItems,
    itemsPrice,
    totalAmount,
    currency,
    buyerInfo,
    status: 'PENDING', // 👈 Limpio
  });

  res.status(201).json(order);
});

// @desc    Obtener todas las órdenes del usuario autenticado
// @route   GET /api/v1/orders/myorders
// @access  Private
export const getMyOrders = asyncHandler(async (req, res) => {
  const orders = await Order.find({ user: req.user._id })
    .sort({ createdAt: -1 });

  res.status(200).json(orders);
});

// @desc    Obtener una orden por ID
// @route   GET /api/v1/orders/:id
// @access  Private
export const getOrderById = asyncHandler(async (req, res) => {
  const { id } = req.params;
  console.log('============= 🔥 ENTRÓ A GET_ORDER_BY_ID ==============');

  if (!mongoose.Types.ObjectId.isValid(id)) {
    return res.status(400).json({ success: false, message: 'ID inválido', data: null });
  }

  const order = await Order.findById(id);

  if (!order) {
    // 🎯 Devolvemos data: null explícito para que el DataSource de Flutter 
    // sepa que no hay mapa que parsear y maneje el estado de error limpiamente
    return res.status(404).json({ success: false, message: 'Orden no encontrada', data: null });
  }

  res.json({
    success: true,
    data: {
      _id: order._id,
      items: (order.items || []).map(item => ({
        productId: item.productId,
        name: item.name,
        quantity: item.quantity,
        price: item.unitPrice || item.price || 0,
        unitPrice: item.unitPrice || item.price || 0,
        imageUrl: item.imageUrl || ''
      })),
      itemsPrice: order.itemsPrice || 0,
      tax: order.tax || 0,
      totalAmount: order.totalAmount || 0,
      status: order.status || 'PENDING',
      createdAt: order.createdAt,
      paymentMethod: order.paymentMethod || null,
      shipping: order.shipping ? {
        method: order.shipping.method || 'pickup',
        cost: order.shipping.cost || 0,
        carrierName: order.shipping.carrierName || '',
        serviceType: order.shipping.serviceType || '',
        address: order.shipping.address || null,
        tracking: order.shipping.tracking || { status: 'pending_label' }
      } : {
        method: 'pickup',
        cost: 0,
        tracking: { status: 'pending_label' }
      }
    }
  });
});

// @desc    Obtener todas las órdenes (Admin)
// @route   GET /api/v1/orders
// @access  Private/Admin
export const getAllOrders = asyncHandler(async (req, res) => {
  const orders = await Order.find({})
    .populate('user', 'id name')
    .sort({ createdAt: -1 });

  res.status(200).json(orders);
});

// @desc    Marcar orden como pagada
// @route   PUT /api/v1/orders/:id/pay
// @access  Private/Admin
export const updateOrderToPaid = asyncHandler(async (req, res) => {
  const order = await Order.findById(req.params.id);

  if (!order) {
    res.status(404);
    throw new Error('Orden no encontrada');
  }

  order.status = 'PAID';
  order.paidAt = Date.now();
  order.paymentDetails = {
    paymentId: req.body.paymentId,
    preferenceId: req.body.preferenceId,
    method: 'mercadopago',
    statusDetail: req.body.statusDetail,
  };

  const updatedOrder = await order.save();
  res.json(updatedOrder);
});



export const getOrderStatus = asyncHandler(async (req, res) => {
  console.log('============= 🎯 ENTRÓ A GET_ORDER_STATUS ==============');
  const order = await Order.findById(req.params.id);

  if (!order) {
    res.status(404);
    throw new Error('Orden no encontrada');
  }

  // 🧪 MODO SIMULACIÓN PROFESIONAL: 
  // Si la orden está pendiente, la pasamos a PAID simulando el éxito de Mercado Pago
  if (order.status === 'PENDING' || order.status === 'WAITING_PAYMENT') {
    order.status = 'PAID';
    order.paidAt = Date.now();
    order.paymentDetails = {
      paymentId: "99999999",
      method: 'mercadopago_mock',
      statusDetail: 'accredited',
    };
    await order.save(); // Guardamos el cambio real en MongoDB
    console.log('✅ [SIMULADOR] Orden marcada como PAGADA con éxito.');
  }

  // 🔒 Seguridad: Validación contra nulos si el usuario no está logueado
  const orderUserId = order.user ? order.user.toString() : null;
  const currentUserId = req.user?._id ? req.user._id.toString() : null;

  if (orderUserId && orderUserId !== currentUserId && req.user?.role !== 'admin') {
    return res.status(403).json({ success: false, message: 'No autorizado' });
  }

  res.json({
    success: true,
    status: order.status,
    paidAt: order.paidAt,
    paymentDetails: order.paymentDetails,
  });
});