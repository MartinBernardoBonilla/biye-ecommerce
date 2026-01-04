// src/controllers/categories.controller.js
// Lógica para las rutas de categorías (ES Modules)
import Category from '../models/Category.js';

// @route   POST /api/v1/categories
// @desc    Crear una nueva categoría
// @access  Private/Admin
export const createCategory = async (req, res) => {
    try {
        const { name, description, image } = req.body;
        const category = await Category.create({ name, description, image });
        res.status(201).json({ success: true, data: category });
    } catch (error) {
        res.status(400).json({ success: false, error: error.message });
    }
};

// @route   GET /api/v1/categories
// @desc    Obtener todas las categorías
// @access  Public
export const getCategories = async (req, res) => {
    try {
        const categories = await Category.find();
        res.status(200).json({ 
            success: true, 
            count: categories.length, 
            data: categories 
        });
    } catch (error) {
        res.status(500).json({ 
            success: false, 
            error: 'Error del servidor',
            message: error.message 
        });
    }
};

// @route   GET /api/v1/categories/:id
// @desc    Obtener una sola categoría por ID
// @access  Public
export const getCategory = async (req, res) => {
    try {
        const category = await Category.findById(req.params.id);
        if (!category) {
            return res.status(404).json({ 
                success: false, 
                error: 'Categoría no encontrada' 
            });
        }
        res.status(200).json({ success: true, data: category });
    } catch (error) {
        res.status(500).json({ 
            success: false, 
            error: 'Error del servidor' 
        });
    }
};

// @route   PUT /api/v1/categories/:id
// @desc    Actualizar una categoría por ID
// @access  Private/Admin
export const updateCategory = async (req, res) => {
    try {
        const category = await Category.findByIdAndUpdate(req.params.id, req.body, {
            new: true,
            runValidators: true,
        });
        if (!category) {
            return res.status(404).json({ 
                success: false, 
                error: 'Categoría no encontrada' 
            });
        }
        res.status(200).json({ success: true, data: category });
    } catch (error) {
        res.status(400).json({ 
            success: false, 
            error: error.message 
        });
    }
};

// @route   DELETE /api/v1/categories/:id
// @desc    Eliminar una categoría por ID
// @access  Private/Admin
export const deleteCategory = async (req, res) => {
    try {
        const category = await Category.findById(req.params.id);
        if (!category) {
            return res.status(404).json({ 
                success: false, 
                error: 'Categoría no encontrada' 
            });
        }
        await category.deleteOne();
        res.status(200).json({ success: true, data: {} });
    } catch (error) {
        res.status(500).json({ 
            success: false, 
            error: 'Error del servidor' 
        });
    }
};

