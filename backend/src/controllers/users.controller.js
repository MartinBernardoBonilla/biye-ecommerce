import asyncHandler from '../middleware/asyncHandler.middleware.js';
import User from '../models/user.js';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';

/**
 * POST /api/v1/users/register
 */
export const registerUser = asyncHandler(async (req, res) => {
    const { username, email, password } = req.body;

    const userExists = await User.findOne({ email });
    if (userExists) {
        res.status(400);
        throw new Error('El usuario ya existe');
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const user = await User.create({
        username,
        email,
        password: hashedPassword,
    });

    const token = jwt.sign(
        { user: { id: user.id, isAdmin: user.isAdmin } },
        process.env.JWT_SECRET,
        { expiresIn: '1h' }
    );

    res.status(201).json({
        success: true,
        token,
        user: {
            id: user.id,
            username: user.username,
            email: user.email,
            isAdmin: user.isAdmin,
        },
    });
});

/**
 * POST /api/v1/users/login
 */
export const loginUser = asyncHandler(async (req, res) => {
    const { email, password } = req.body;

    const user = await User.findOne({ email });
    if (!user) {
        res.status(400);
        throw new Error('Credenciales inválidas');
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
        res.status(400);
        throw new Error('Credenciales inválidas');
    }

    const token = jwt.sign(
        { user: { id: user.id, isAdmin: user.isAdmin } },
        process.env.JWT_SECRET,
        { expiresIn: '1h' }
    );

    res.status(200).json({
        success: true,
        token,
        user: {
            id: user.id,
            username: user.username,
            email: user.email,
            isAdmin: user.isAdmin,
        },
    });
});

/**
 * GET /api/v1/users/me
 */
export const getMe = asyncHandler(async (req, res) => {
    const user = await User.findById(req.user.id).select('-password');

    if (!user) {
        res.status(404);
        throw new Error('Usuario no encontrado');
    }

    res.status(200).json(user);
});

/**
 * PUT /api/v1/users/:id
 */
export const updateUser = asyncHandler(async (req, res) => {
    const user = await User.findById(req.params.id);

    if (!user) {
        res.status(404);
        throw new Error('Usuario no encontrado');
    }

    user.username = req.body.username ?? user.username;
    user.email = req.body.email ?? user.email;
    user.isAdmin = req.body.isAdmin ?? user.isAdmin;

    const updatedUser = await user.save();
    res.status(200).json(updatedUser);
});

/**
 * DELETE /api/v1/users/:id
 */
export const deleteUser = asyncHandler(async (req, res) => {
    const user = await User.findById(req.params.id);

    if (!user) {
        res.status(404);
        throw new Error('Usuario no encontrado');
    }

    await user.deleteOne();

    res.status(200).json({
        success: true,
        message: 'Usuario eliminado',
    });
});

/**
 * GET /api/v1/users
 */
export const getAllUsers = asyncHandler(async () => {
    return await User.find().select('-password');
});
