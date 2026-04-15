import asyncHandler from '../middleware/asyncHandler.middleware.js';
import Order from '../models/order.js';
import Product from '../models/product.model.js';



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
    user: req.user?._id || null, // 👈 CLAVE
    items: orderItems,
    itemsPrice,
    totalAmount,
    currency,
    buyerInfo,
    status: 'WAITING_PAYMENT',
    status: 'PENDING',
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

  if (!mongoose.Types.ObjectId.isValid(id)) {
    return res.status(400).json({ success: false });
  }

  const order = await Order.findById(id);

  if (!order) {
    return res.status(404).json({ success: false });
  }

  res.json({
    success: true,
    data: {
      id: order._id,
      status: order.status,
      totalAmount: order.totalAmount,
      paidAt: order.paidAt,
    },
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
  const order = await Order.findById(req.params.id);

  if (!order) {
    res.status(404);
    throw new Error('Orden no encontrada');
  }

  // Seguridad: solo dueño o admin
  if (
    order.user.toString() !== req.user._id.toString() &&
    req.user.role !== 'admin'
  ) {
    res.status(403);
    throw new Error('No autorizado');
  }

  res.json({
    success: true,
    status: order.status,
    paidAt: order.paidAt,
    paymentDetails: order.paymentDetails,
  });
});

