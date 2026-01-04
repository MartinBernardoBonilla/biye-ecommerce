import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/services/admin_service.dart';

class AdminCreateProductPage extends StatefulWidget {
  static const routeName = '/admin-create-product';

  const AdminCreateProductPage({super.key});

  @override
  State<AdminCreateProductPage> createState() => _AdminCreateProductPageState();
}

class _AdminCreateProductPageState extends State<AdminCreateProductPage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _stockController = TextEditingController();

  // Estado para la imagen
  dynamic _pickedImage; // Puede ser File (móvil) o XFile (web)
  bool _isLoading = false;
  Uint8List? _imageBytes; // Para web

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  // Lógica para seleccionar una imagen
  Future<void> _pickImage() async {
    final picker = ImagePicker();

    // Abre la galería
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedImage = pickedFile;
        if (kIsWeb) {
          // En web, guardamos también los bytes para previsualización
          _loadImageBytes(pickedFile);
        }
      });
      print('🖼️ Imagen seleccionada: ${pickedFile.name}');
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selección de imagen cancelada.')),
        );
      }
    }
  }

  // Cargar bytes de la imagen (solo web)
  Future<void> _loadImageBytes(XFile xfile) async {
    final bytes = await xfile.readAsBytes();
    setState(() {
      _imageBytes = bytes;
    });
  }

  // Preparar archivo para upload (compatible web/móvil) - VERSIÓN MEJORADA
  Future<File> _prepareImageForUpload() async {
    if (_pickedImage == null) {
      throw Exception('No hay imagen seleccionada');
    }

    try {
      if (kIsWeb) {
        // Para web: XFile viene del ImagePicker
        final xfile = _pickedImage as XFile;
        final bytes = await xfile.readAsBytes();

        // Crear archivo temporal
        final tempDir = await Directory.systemTemp.createTemp();
        final fileName = xfile.name.isNotEmpty
            ? xfile.name
            : 'product_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final tempFile = File('${tempDir.path}/$fileName');
        await tempFile.writeAsBytes(bytes);

        print('🖼️ Imagen preparada para web: ${tempFile.path}');
        return tempFile;
      } else {
        // Para móvil/desktop
        if (_pickedImage is File) {
          final file = _pickedImage as File;
          print('🖼️ Imagen File: ${file.path}');
          return file;
        } else if (_pickedImage is XFile) {
          final xfile = _pickedImage as XFile;
          final file = File(xfile.path);
          print('🖼️ Imagen XFile convertida: ${file.path}');
          return file;
        } else {
          throw Exception(
            'Tipo de imagen no soportado: ${_pickedImage.runtimeType}',
          );
        }
      }
    } catch (e) {
      print('❌ Error al preparar imagen: $e');
      throw Exception('Error al preparar la imagen: $e');
    }
  }

  // Widget para mostrar la imagen previsualizada
  Widget _buildImagePreview() {
    if (_pickedImage == null) {
      return const Text('No hay imagen', textAlign: TextAlign.center);
    }

    if (kIsWeb) {
      // Para web: mostrar desde bytes
      if (_imageBytes != null) {
        return Image.memory(
          _imageBytes!,
          fit: BoxFit.cover,
          width: 100,
          height: 100,
        );
      } else {
        return Container(
          width: 100,
          height: 100,
          color: Colors.grey,
          child: const Center(child: CircularProgressIndicator()),
        );
      }
    } else {
      // Para móvil/desktop: mostrar desde File
      return Image.file(
        File((_pickedImage as XFile).path),
        fit: BoxFit.cover,
        width: 100,
        height: 100,
      );
    }
  }

  // Función de manejo del envío
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_pickedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecciona una imagen para el producto.'),
          ),
        );
        return;
      }

      _formKey.currentState!.save();

      if (!mounted) return;

      setState(() {
        _isLoading = true;
      });

      try {
        final adminService = Provider.of<AdminService>(context, listen: false);

        // Preparar imagen para upload
        final imageFile = await _prepareImageForUpload();

        await adminService.addProduct(
          name: _nameController.text,
          price: double.parse(_priceController.text),
          description: _descriptionController.text,
          category: _categoryController.text,
          imageFile: imageFile,
          countInStock: int.parse(_stockController.text),
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto creado exitosamente!')),
        );
        // Regresar a la pantalla de gestión de productos
        Navigator.of(context).pop();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al crear producto: $e')));
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  // --- CAMPO DE NOMBRE ---
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Producto',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el nombre.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // --- CAMPO DE PRECIO ---
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: 'Precio'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      final price = double.tryParse(value ?? '');
                      if (price == null || price <= 0) {
                        return 'Por favor ingresa un precio válido (> 0).';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // --- CAMPO DE DESCRIPCIÓN ---
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa una descripción.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // --- CAMPO DE CATEGORÍA ---
                  TextFormField(
                    controller: _categoryController,
                    decoration: const InputDecoration(labelText: 'Categoría'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa una categoría.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // --- CAMPO DE STOCK (countInStock) ---
                  TextFormField(
                    controller: _stockController,
                    decoration: const InputDecoration(
                      labelText: 'Stock (Cantidad en inventario)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final stock = int.tryParse(value ?? '');
                      if (stock == null || stock < 0) {
                        return 'Por favor ingresa un número de stock válido (>= 0).';
                      }
                      return null;
                    },
                  ),

                  // --- WIDGET PARA SELECCIÓN DE IMAGEN ---
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

                  // --- BOTÓN DE GUARDAR ---
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      _isLoading ? 'Guardando...' : 'Guardar Producto',
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Overlay de carga
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
