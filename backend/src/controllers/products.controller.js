// src/controllers/products.controller.js

import asyncHandler from '../middleware/asyncHandler.middleware.js';
import Product from '../models/Product.model.js';


/* =======================
   PÚBLICO
======================= */

// GET /api/v1/products
export const getProducts = asyncHandler(async (req, res) => {
  const products = await Product.find({ isActive: true }).sort({ createdAt: -1 });

  res.status(200).json({
    success: true,
    count: products.length,
    data: products,
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

/* =======================
   ADMIN
======================= */

// GET /api/v1/admin/products
export const getAdminProducts = asyncHandler(async (req, res) => {
  const products = await Product.find().sort({ createdAt: -1 });

  res.status(200).json({
    success: true,
    count: products.length,
    data: products,
  });
});

// POST /api/v1/admin/products
export const createProduct = asyncHandler(async (req, res) => {
  req.body.user = req.user._id;

const product = await Product.create(req.body);


  res.status(201).json({
    success: true,
    data: product,
  });
});

// PATCH /api/v1/admin/products/:id
export const updateProduct = asyncHandler(async (req, res) => {
  const product = await Product.findByIdAndUpdate(
    req.params.id,
    req.body,
    { new: true, runValidators: true }
  );

  if (!product) {
    res.status(404);
    throw new Error('Producto no encontrado');
  }

  res.status(200).json({
    success: true,
    data: product,
  });
});

// DELETE /api/v1/admin/products/:id
export const deleteProduct = asyncHandler(async (req, res) => {
  const product = await Product.findById(req.params.id);

  if (!product) {
    res.status(404);
    throw new Error('Producto no encontrado');
  }

  await product.deleteOne();

  res.status(200).json({
    success: true,
    message: 'Producto eliminado',
  });
});
