import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Rutas relativas CORRECTAS
import '../../../product/data/models/product_model.dart';
import '../../data/services/admin_service.dart';
import 'admin_create_product_page.dart';
import 'admin_edit_product_page.dart';

// ⭐️ SOLO UNA DEFINICIÓN DE ESTA CLASE
class ProductManagementPage extends StatefulWidget {
  static const String routeName = '/admin-product-management';

  const ProductManagementPage({super.key});

  @override
  State<ProductManagementPage> createState() => _ProductManagementPageState();
}

class _ProductManagementPageState extends State<ProductManagementPage> {
  late Future<List<ProductModel>> _productsFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    _productsFuture = _fetchProducts();
  }

  Future<List<ProductModel>> _fetchProducts() async {
    final adminService = Provider.of<AdminService>(context, listen: false);
    return adminService.getAdminProducts();
  }

  Future<void> _refreshProducts() async {
    if (mounted) {
      setState(() {
        _loadProducts();
      });
    }
  }

  Future<void> _deleteProduct(String productId) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final adminService = Provider.of<AdminService>(context, listen: false);
      await adminService.deleteProduct(productId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Producto eliminado con éxito'),
            backgroundColor: Colors.green,
          ),
        );
        _refreshProducts();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '❌ Error: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _restoreProduct(ProductModel product) async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final adminService = Provider.of<AdminService>(context, listen: false);

      await adminService.updateProduct(
        product.id ?? '',
        {'isActive': true},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Producto restaurado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        _refreshProducts();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '❌ Error: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showDeleteConfirmation(String productId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content:
            const Text('¿Estás seguro de que deseas eliminar este producto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteProduct(productId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Productos'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Crear nuevo producto',
            onPressed: () {
              Navigator.of(context)
                  .pushNamed(AdminCreateProductPage.routeName)
                  .then((result) {
                if (result == true && mounted) {
                  _refreshProducts();
                }
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refreshProducts,
            child: FutureBuilder<List<ProductModel>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Error: ${snapshot.error.toString().replaceFirst('Exception: ', '')}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.inventory_2_outlined,
                          size: 50,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No hay productos cargados',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed(AdminCreateProductPage.routeName);
                          },
                          child: const Text('Crear primer producto'),
                        ),
                      ],
                    ),
                  );
                }

                final products = snapshot.data!;
                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final isInactive = !product.isActive;
                    final isLowStock =
                        product.countInStock <= 10 && product.countInStock > 0;
                    final isOutOfStock = product.countInStock <= 0;
                    final productId = product.id ?? '';

                    return Card(
                      color: isInactive ? Colors.grey[100]! : Colors.white,
                      margin: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[200]!,
                          child: product.image?.url != null
                              ? ClipOval(
                                  child: Image.network(
                                    product.image!.url,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(Icons.shopping_bag,
                                  color: Colors.grey),
                        ),
                        title: Text(
                          isInactive
                              ? '${product.name} (Inactivo)'
                              : product.name,
                          style: TextStyle(
                            fontWeight: isInactive
                                ? FontWeight.normal
                                : FontWeight.bold,
                            decoration: isInactive
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            color:
                                isInactive ? Colors.grey[600]! : Colors.black,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Precio: \$${product.price.toStringAsFixed(2)}'),
                            Text(
                              'Stock: ${product.countInStock}',
                              style: TextStyle(
                                color: isOutOfStock
                                    ? Colors.red
                                    : isLowStock
                                        ? Colors.orange
                                        : Colors.green,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                isInactive ? Icons.restore : Icons.edit,
                                color: isInactive ? Colors.green : Colors.blue,
                              ),
                              tooltip: isInactive
                                  ? 'Restaurar producto'
                                  : 'Editar producto',
                              onPressed: _isLoading
                                  ? null
                                  : () async {
                                      if (isInactive) {
                                        await _restoreProduct(product);
                                      } else {
                                        Navigator.of(context).pushNamed(
                                          AdminEditProductPage.routeName,
                                          arguments: product,
                                        );
                                      }
                                    },
                            ),
                            if (!isInactive && productId.isNotEmpty)
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                tooltip: 'Eliminar producto',
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                        _showDeleteConfirmation(productId);
                                      },
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
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
