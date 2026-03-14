import asyncHandler from '../middleware/asyncHandler.middleware.js';
import Product from '../models/Product.model.js';
import cloudinary from '../config/cloudinary.js';

/* =======================
   PÚBLICO
======================= */

// GET /api/v1/products
export const getProducts = asyncHandler(async (req, res) => {
  const page = Number(req.query.page) || 1;
  const limit = Number(req.query.limit) || 12;
  const skip = (page - 1) * limit;

  const filter = { isActive: true };

  if (req.query.category) {
    filter.category = req.query.category;
  }

  if (req.query.search) {
    filter.name = {
      $regex: req.query.search,
      $options: 'i',
    };
  }

  // 🔽 Ordenamiento
  let sort = { createdAt: -1 };

  switch (req.query.sort) {
    case 'price':
      sort = { price: 1 };
      break;
    case '-price':
      sort = { price: -1 };
      break;
    case 'new':
      sort = { createdAt: -1 };
      break;
  }

  const total = await Product.countDocuments(filter);

  const products = await Product.find(filter)
    .sort(sort)
    .skip(skip)
    .limit(limit);

  res.status(200).json({
    success: true,
    page,
    pages: Math.ceil(total / limit),
    count: products.length,
    total,
    data: products,
  });
});


// GET /api/v1/products/categories
export const getProductCategories = asyncHandler(async (req, res) => {
  const categories = await Product.distinct('category', {
    isActive: true,
  });

  res.status(200).json({
    success: true,
    count: categories.length,
    data: categories.sort(),
  });
});

// GET /api/v1/products/:id
export const getProductById = asyncHandler(async (req, res) => {
  const product = await Product.findById(req.params.id);

  if (!product || product.isActive === false) {
    res.status(404);
    throw new Error('Producto no encontrado');
  }

  res.status(200).json({
    success: true,
    data: product,
  });
});

// GET /api/v1/products/featured
export const getFeaturedProducts = asyncHandler(async (req, res) => {
  const products = await Product.find({
    isActive: true,
    featured: true,
  })
    .sort({ createdAt: -1 })
    .limit(8);

  res.status(200).json({
    success: true,
    count: products.length,
    data: products,
  });
});



/* =======================
   ADMIN
======================= */

// GET /api/v1/admin/products
export const getAdminProducts = asyncHandler(async (req, res) => {
  const { filter } = req.query;
  let query = {};
  
  console.log('🔍 [ADMIN PRODUCTS] Filtro recibido:', filter);
  
  // Aplicar filtros según el parámetro
  switch (filter) {
    case 'lowStock':
      // Productos con stock entre 1 y 10
      query = { countInStock: { $gt: 0, $lt: 10 } };
      console.log('📦 Aplicando filtro: stock bajo');
      break;
    case 'outOfStock':
      // Productos sin stock
      query = { countInStock: 0 };
      console.log('📦 Aplicando filtro: sin stock');
      break;
    case 'active':
      // Productos activos
      query = { isActive: true };
      console.log('📦 Aplicando filtro: activos');
      break;
    default:
      // Todos los productos (sin filtro)
      query = {};
      console.log('📦 Sin filtro - todos los productos');
  }
  
  const products = await Product.find(query)
    .sort({ createdAt: -1 })
    .lean();
  
  console.log(`📊 Productos encontrados: ${products.length}`);
  
  res.json({
    success: true,
    data: products,
    count: products.length,
    filter: filter || 'none'
  });
});
// POST /api/v1/admin/products
export const createProduct = asyncHandler(async (req, res) => {
  req.body.user = req.user._id;

  if (req.cloudinaryImage) {
    req.body.image = req.cloudinaryImage;
  }

  const product = await Product.create(req.body);

  res.status(201).json({
    success: true,
    data: product,
  });
});

// PATCH /api/v1/admin/products/:id
export const updateProduct = asyncHandler(async (req, res) => {
  const product = await Product.findById(req.params.id);

  if (!product) {
    res.status(404);
    throw new Error('Producto no encontrado');
  }

  if (req.cloudinaryImage) {
    if (product.image?.public_id) {
      try {
        await cloudinary.uploader.destroy(product.image.public_id);
      } catch (err) {
        console.warn('⚠️ Error borrando imagen vieja:', err.message);
      }
    }

    req.body.image = req.cloudinaryImage;
  }

  const updatedProduct = await Product.findByIdAndUpdate(
    req.params.id,
    req.body,
    { new: true, runValidators: true }
  );

  res.status(200).json({
    success: true,
    data: updatedProduct,
  });
});

// DELETE /api/v1/admin/products/:id
export const deleteProduct = asyncHandler(async (req, res) => {
  const product = await Product.findById(req.params.id);

  if (!product) {
    res.status(404);
    throw new Error('Producto no encontrado');
  }

  if (product.image?.public_id) {
    try {
      await cloudinary.uploader.destroy(product.image.public_id);
    } catch (err) {
      console.warn('⚠️ Error borrando imagen:', err.message);
    }
  }

  await product.deleteOne();

  res.status(200).json({
    success: true,
    message: 'Producto eliminado correctamente',
  });
});
