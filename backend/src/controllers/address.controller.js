import Address from '../models/Address.js';

// Obtener todas las direcciones del usuario
export const getAddresses = async (req, res) => {
  try {
    const addresses = await Address.find({ user: req.user.id })
      .sort({ isDefault: -1, createdAt: -1 });
    
    res.json({
      success: true,
      count: addresses.length,
      addresses
    });
  } catch (error) {
    console.error('Error getting addresses:', error);
    res.status(500).json({
      success: false,
      message: 'Error al obtener direcciones',
      error: error.message
    });
  }
};

// Obtener una dirección por ID
export const getAddressById = async (req, res) => {
  try {
    const address = await Address.findOne({
      _id: req.params.id,
      user: req.user.id
    });
    
    if (!address) {
      return res.status(404).json({
        success: false,
        message: 'Dirección no encontrada'
      });
    }
    
    res.json({
      success: true,
      address
    });
  } catch (error) {
    console.error('Error getting address:', error);
    res.status(500).json({
      success: false,
      message: 'Error al obtener dirección',
      error: error.message
    });
  }
};

// Crear nueva dirección
export const createAddress = async (req, res) => {
  try {
    const { isDefault, ...addressData } = req.body;
    
    // Si es la primera dirección del usuario, forzar como default
    const existingCount = await Address.countDocuments({ user: req.user.id });
    const shouldBeDefault = isDefault || existingCount === 0;
    
    const address = await Address.create({
      ...addressData,
      user: req.user.id,
      isDefault: shouldBeDefault
    });
    
    res.status(201).json({
      success: true,
      message: 'Dirección creada exitosamente',
      address
    });
  } catch (error) {
    console.error('Error creating address:', error);
    
    if (error.code === 11000) {
      return res.status(400).json({
        success: false,
        message: 'Ya existe una dirección con este alias'
      });
    }
    
    res.status(500).json({
      success: false,
      message: 'Error al crear dirección',
      error: error.message
    });
  }
};

// Actualizar dirección
export const updateAddress = async (req, res) => {
  try {
    const address = await Address.findOne({
      _id: req.params.id,
      user: req.user.id
    });
    
    if (!address) {
      return res.status(404).json({
        success: false,
        message: 'Dirección no encontrada'
      });
    }
    
    const { isDefault, ...updateData } = req.body;
    
    // Actualizar campos
    Object.assign(address, updateData);
    
    if (isDefault !== undefined) {
      address.isDefault = isDefault;
    }
    
    await address.save();
    
    res.json({
      success: true,
      message: 'Dirección actualizada exitosamente',
      address
    });
  } catch (error) {
    console.error('Error updating address:', error);
    res.status(500).json({
      success: false,
      message: 'Error al actualizar dirección',
      error: error.message
    });
  }
};

// Eliminar dirección
export const deleteAddress = async (req, res) => {
  try {
    const address = await Address.findOneAndDelete({
      _id: req.params.id,
      user: req.user.id
    });
    
    if (!address) {
      return res.status(404).json({
        success: false,
        message: 'Dirección no encontrada'
      });
    }
    
    // Si eliminamos la dirección default, marcar otra como default
    if (address.isDefault) {
      const nextAddress = await Address.findOne({ user: req.user.id });
      if (nextAddress) {
        nextAddress.isDefault = true;
        await nextAddress.save();
      }
    }
    
    res.json({
      success: true,
      message: 'Dirección eliminada exitosamente'
    });
  } catch (error) {
    console.error('Error deleting address:', error);
    res.status(500).json({
      success: false,
      message: 'Error al eliminar dirección',
      error: error.message
    });
  }
};

// Establecer dirección como default
export const setDefaultAddress = async (req, res) => {
  try {
    await Address.updateMany(
      { user: req.user.id },
      { isDefault: false }
    );
    
    const address = await Address.findOneAndUpdate(
      { _id: req.params.id, user: req.user.id },
      { isDefault: true },
      { new: true }
    );
    
    if (!address) {
      return res.status(404).json({
        success: false,
        message: 'Dirección no encontrada'
      });
    }
    
    res.json({
      success: true,
      message: 'Dirección predeterminada actualizada',
      address
    });
  } catch (error) {
    console.error('Error setting default address:', error);
    res.status(500).json({
      success: false,
      message: 'Error al establecer dirección predeterminada',
      error: error.message
    });
  }
};