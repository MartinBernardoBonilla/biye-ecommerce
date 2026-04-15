import PaymentMethod from '../models/paymentMethod.js';

// Obtener todos los métodos de pago del usuario
export const getPaymentMethods = async (req, res) => {
  try {
    const methods = await PaymentMethod.find({ user: req.user.id, isActive: true })
      .sort({ isDefault: -1, createdAt: -1 });
    
    res.json({
      success: true,
      count: methods.length,
      methods
    });
  } catch (error) {
    console.error('Error getting payment methods:', error);
    res.status(500).json({
      success: false,
      message: 'Error al obtener métodos de pago',
      error: error.message
    });
  }
};

// Obtener método de pago por ID
export const getPaymentMethodById = async (req, res) => {
  try {
    const method = await PaymentMethod.findOne({
      _id: req.params.id,
      user: req.user.id
    });
    
    if (!method) {
      return res.status(404).json({
        success: false,
        message: 'Método de pago no encontrado'
      });
    }
    
    res.json({
      success: true,
      method
    });
  } catch (error) {
    console.error('Error getting payment method:', error);
    res.status(500).json({
      success: false,
      message: 'Error al obtener método de pago',
      error: error.message
    });
  }
};

// Agregar tarjeta de crédito/débito
export const addCard = async (req, res) => {
  try {
    const { lastFourDigits, brand, expirationMonth, expirationYear, cardholderName, isDefault } = req.body;
    
    // Validar
    if (!lastFourDigits || !brand || !expirationMonth || !expirationYear || !cardholderName) {
      return res.status(400).json({
        success: false,
        message: 'Todos los campos de tarjeta son requeridos'
      });
    }
    
    const existingCount = await PaymentMethod.countDocuments({ user: req.user.id });
    const shouldBeDefault = isDefault || existingCount === 0;
    
    const paymentMethod = await PaymentMethod.create({
      user: req.user.id,
      type: 'card',
      cardDetails: {
        lastFourDigits,
        brand,
        expirationMonth,
        expirationYear,
        cardholderName
      },
      isDefault: shouldBeDefault
    });
    
    res.status(201).json({
      success: true,
      message: 'Tarjeta agregada exitosamente',
      method: paymentMethod
    });
  } catch (error) {
    console.error('Error adding card:', error);
    res.status(500).json({
      success: false,
      message: 'Error al agregar tarjeta',
      error: error.message
    });
  }
};

// Eliminar método de pago
export const deletePaymentMethod = async (req, res) => {
  try {
    const method = await PaymentMethod.findOneAndDelete({
      _id: req.params.id,
      user: req.user.id
    });
    
    if (!method) {
      return res.status(404).json({
        success: false,
        message: 'Método de pago no encontrado'
      });
    }
    
    // Si eliminamos el default, marcar otro como default
    if (method.isDefault) {
      const nextMethod = await PaymentMethod.findOne({ user: req.user.id });
      if (nextMethod) {
        nextMethod.isDefault = true;
        await nextMethod.save();
      }
    }
    
    res.json({
      success: true,
      message: 'Método de pago eliminado exitosamente'
    });
  } catch (error) {
    console.error('Error deleting payment method:', error);
    res.status(500).json({
      success: false,
      message: 'Error al eliminar método de pago',
      error: error.message
    });
  }
};

// Establecer método como default
export const setDefaultPaymentMethod = async (req, res) => {
  try {
    await PaymentMethod.updateMany(
      { user: req.user.id },
      { isDefault: false }
    );
    
    const method = await PaymentMethod.findOneAndUpdate(
      { _id: req.params.id, user: req.user.id },
      { isDefault: true },
      { new: true }
    );
    
    if (!method) {
      return res.status(404).json({
        success: false,
        message: 'Método de pago no encontrado'
      });
    }
    
    res.json({
      success: true,
      message: 'Método de pago predeterminado actualizado',
      method
    });
  } catch (error) {
    console.error('Error setting default payment method:', error);
    res.status(500).json({
      success: false,
      message: 'Error al establecer método de pago predeterminado',
      error: error.message
    });
  }
};