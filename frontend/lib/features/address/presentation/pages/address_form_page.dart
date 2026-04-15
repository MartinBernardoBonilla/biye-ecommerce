import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:biye/features/address/presentation/bloc/address_bloc.dart';
import 'package:biye/features/address/presentation/bloc/address_event.dart';
import 'package:biye/features/address/presentation/bloc/address_state.dart';
import 'package:biye/features/address/domain/entities/address.dart';

class AddressFormPage extends StatefulWidget {
  final Address? address;

  const AddressFormPage({super.key, this.address});

  @override
  State<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<AddressFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _aliasController = TextEditingController();
  final _recipientNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _apartmentController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController();
  final _instructionsController = TextEditingController();
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      _loadAddressData();
    }
    _countryController.text = 'Argentina';
  }

  void _loadAddressData() {
    final address = widget.address!;
    _aliasController.text = address.alias;
    _recipientNameController.text = address.recipientName;
    _phoneController.text = address.phone;
    _streetController.text = address.street;
    _numberController.text = address.number;
    _apartmentController.text = address.apartment ?? '';
    _cityController.text = address.city;
    _stateController.text = address.state;
    _postalCodeController.text = address.postalCode;
    _countryController.text = address.country;
    _instructionsController.text = address.instructions ?? '';
    _isDefault = address.isDefault;
  }

  @override
  void dispose() {
    _aliasController.dispose();
    _recipientNameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _apartmentController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final address = Address(
      id: widget.address?.id ?? '',
      alias: _aliasController.text.trim(),
      recipientName: _recipientNameController.text.trim(),
      phone: _phoneController.text.trim(),
      street: _streetController.text.trim(),
      number: _numberController.text.trim(),
      apartment: _apartmentController.text.trim().isEmpty
          ? null
          : _apartmentController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      postalCode: _postalCodeController.text.trim(),
      country: _countryController.text.trim(),
      isDefault: _isDefault,
      instructions: _instructionsController.text.trim().isEmpty
          ? null
          : _instructionsController.text.trim(),
      createdAt: widget.address?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.address == null) {
      context.read<AddressBloc>().add(CreateAddress(address: address));
    } else {
      context.read<AddressBloc>().add(UpdateAddress(address: address));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Guardando dirección...'),
        duration: Duration(seconds: 1),
      ),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.address == null ? 'Nueva Dirección' : 'Editar Dirección'),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocListener<AddressBloc, AddressState>(
        listener: (context, state) {
          if (state is AddressSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
          if (state is AddressError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Alias
                TextFormField(
                  controller: _aliasController,
                  decoration: const InputDecoration(
                    labelText: 'Alias *',
                    hintText: 'Ej: Casa, Oficina, etc.',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa un alias';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Nombre del destinatario
                TextFormField(
                  controller: _recipientNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del destinatario *',
                    hintText: 'Nombre completo',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa el nombre del destinatario';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Teléfono
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono *',
                    hintText: 'Ej: 11 1234-5678',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa un teléfono de contacto';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Calle y número
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _streetController,
                        decoration: const InputDecoration(
                          labelText: 'Calle *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Requerido';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _numberController,
                        decoration: const InputDecoration(
                          labelText: 'Número *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Requerido';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Apartamento/Piso
                TextFormField(
                  controller: _apartmentController,
                  decoration: const InputDecoration(
                    labelText: 'Piso / Departamento',
                    hintText: 'Opcional',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Ciudad y Provincia
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(
                          labelText: 'Ciudad *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Requerido';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _stateController,
                        decoration: const InputDecoration(
                          labelText: 'Provincia *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Requerido';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Código Postal y País
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _postalCodeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Código Postal *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Requerido';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _countryController,
                        decoration: const InputDecoration(
                          labelText: 'País *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Requerido';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Instrucciones adicionales
                TextFormField(
                  controller: _instructionsController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Instrucciones adicionales',
                    hintText: 'Punto de referencia, horarios de entrega, etc.',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Checkbox para dirección predeterminada
                Row(
                  children: [
                    Checkbox(
                      value: _isDefault,
                      onChanged: (value) {
                        setState(() {
                          _isDefault = value ?? false;
                        });
                      },
                    ),
                    const Text('Establecer como dirección predeterminada'),
                  ],
                ),

                const SizedBox(height: 24),

                // Botón guardar
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Guardar dirección',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
