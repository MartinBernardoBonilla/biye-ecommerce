import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/services/admin_service.dart';

class AdminCreateProductPage extends StatefulWidget {
  static const String routeName = '/admin/create-product';

  const AdminCreateProductPage({super.key});

  @override
  State<AdminCreateProductPage> createState() => _AdminCreateProductPageState();
}

class _AdminCreateProductPageState extends State<AdminCreateProductPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _stockController = TextEditingController();

  XFile?
      _pickedImage; // Cambiado a XFile para mejor compatibilidad con ImagePicker
  bool _isLoading = false;
  Uint8List? _imageBytes;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _pickedImage = pickedFile;
        _imageBytes = bytes;
      });
      print('🖼️ Imagen seleccionada: ${pickedFile.name}');
    }
  }

  Widget _buildImagePreview() {
    if (_imageBytes == null) {
      return const Text('No hay imagen', textAlign: TextAlign.center);
    }
    return Image.memory(
      _imageBytes!,
      fit: BoxFit.cover,
      width: 100,
      height: 100,
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_imageBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecciona una imagen.')),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        final adminService = Provider.of<AdminService>(context, listen: false);

        await adminService.createProduct(
          name: _nameController.text,
          price: double.parse(_priceController.text),
          description: _descriptionController.text,
          category: _categoryController.text,
          countInStock: int.parse(_stockController.text),
        );

        if (mounted) Navigator.of(context).pop(true);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al crear producto: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // El build se mantiene igual al que tenías, solo usa _buildImagePreview()
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Nuevo Producto')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextFormField(
                    controller: _nameController,
                    decoration:
                        const InputDecoration(labelText: 'Nombre del Producto'),
                    validator: (value) => (value == null || value.isEmpty)
                        ? 'Ingresa el nombre'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: 'Precio'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      final price = double.tryParse(value ?? '');
                      return (price == null || price <= 0)
                          ? 'Precio inválido'
                          : null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _categoryController,
                    decoration: const InputDecoration(labelText: 'Categoría'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _stockController,
                    decoration: const InputDecoration(labelText: 'Stock'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: _buildImagePreview(),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextButton.icon(
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Seleccionar Imagen'),
                          onPressed: _pickImage,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    child:
                        Text(_isLoading ? 'Guardando...' : 'Guardar Producto'),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
