// lib/core/services/firebase_firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtener referencia del usuario actual
  String? get _currentUserId => _auth.currentUser?.uid;

  // PRODUCTOS

  // Obtener todos los productos
  Stream<List<ProductFirestore>> getProducts() {
    return _firestore
        .collection('products')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ProductFirestore.fromFirestore(doc))
              .toList(),
        );
  }

  // Obtener producto por ID
  Future<ProductFirestore?> getProductById(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      return doc.exists ? ProductFirestore.fromFirestore(doc) : null;
    } catch (e) {
      print('Error getting product: $e');
      return null;
    }
  }

  // Agregar producto (solo admin)
  Future<bool> addProduct(ProductFirestore product) async {
    try {
      await _firestore.collection('products').add(product.toMap());
      return true;
    } catch (e) {
      print('Error adding product: $e');
      return false;
    }
  }

  // Actualizar producto
  Future<bool> updateProduct(
    String productId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating product: $e');
      return false;
    }
  }

  // CARRITO

  // Obtener carrito del usuario
  Stream<List<CartItemFirestore>> getUserCart() {
    if (_currentUserId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('cart')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CartItemFirestore.fromFirestore(doc))
              .toList(),
        );
  }

  // Agregar item al carrito
  Future<bool> addToCart(CartItemFirestore item) async {
    if (_currentUserId == null) return false;

    try {
      final cartRef = _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('cart');

      // Verificar si el item ya existe
      final existingItem = await cartRef.doc(item.productId).get();

      if (existingItem.exists) {
        // Incrementar cantidad
        final currentQuantity = existingItem.data()?['quantity'] ?? 0;
        await cartRef.doc(item.productId).update({
          'quantity': currentQuantity + item.quantity,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Agregar nuevo item
        await cartRef.doc(item.productId).set({
          ...item.toMap(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return true;
    } catch (e) {
      print('Error adding to cart: $e');
      return false;
    }
  }

  // Actualizar cantidad del item en carrito
  Future<bool> updateCartItemQuantity(String productId, int quantity) async {
    if (_currentUserId == null) return false;

    try {
      if (quantity <= 0) {
        return await removeFromCart(productId);
      }

      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('cart')
          .doc(productId)
          .update({
            'quantity': quantity,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      return true;
    } catch (e) {
      print('Error updating cart item quantity: $e');
      return false;
    }
  }

  // Remover item del carrito
  Future<bool> removeFromCart(String productId) async {
    if (_currentUserId == null) return false;

    try {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('cart')
          .doc(productId)
          .delete();

      return true;
    } catch (e) {
      print('Error removing from cart: $e');
      return false;
    }
  }

  // Limpiar carrito
  Future<bool> clearCart() async {
    if (_currentUserId == null) return false;

    try {
      final cartRef = _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('cart');

      final cartItems = await cartRef.get();

      final batch = _firestore.batch();
      for (var doc in cartItems.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      return true;
    } catch (e) {
      print('Error clearing cart: $e');
      return false;
    }
  }

  // PEDIDOS

  // Crear pedido
  Future<String?> createOrder({
    required List<CartItemFirestore> items,
    required double total,
    required String paymentMethod,
    String? paymentId,
  }) async {
    if (_currentUserId == null) return null;

    try {
      final orderRef = _firestore.collection('orders').doc();

      final orderData = {
        'orderId': orderRef.id,
        'userId': _currentUserId,
        'items': items.map((item) => item.toMap()).toList(),
        'total': total,
        'paymentMethod': paymentMethod,
        'paymentId': paymentId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await orderRef.set(orderData);
      return orderRef.id;
    } catch (e) {
      print('Error creating order: $e');
      return null;
    }
  }

  // Obtener pedidos del usuario
  Stream<List<OrderFirestore>> getUserOrders() {
    if (_currentUserId == null) return Stream.value([]);

    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: _currentUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => OrderFirestore.fromFirestore(doc))
              .toList(),
        );
  }

  // Actualizar estado del pedido
  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating order status: $e');
      return false;
    }
  }
}

// MODELOS FIRESTORE

class ProductFirestore {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final int stock;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductFirestore({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.stock = 0,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductFirestore.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductFirestore(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      stock: data['stock'] ?? 0,
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt']?.toDate(),
      updatedAt: data['updatedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'stock': stock,
      'isActive': isActive,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class CartItemFirestore {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CartItemFirestore({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory CartItemFirestore.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CartItemFirestore(
      productId: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      quantity: data['quantity'] ?? 1,
      imageUrl: data['imageUrl'] ?? '',
      createdAt: data['createdAt']?.toDate(),
      updatedAt: data['updatedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  double get totalPrice => price * quantity;
}

class OrderFirestore {
  final String id;
  final String userId;
  final List<CartItemFirestore> items;
  final double total;
  final String paymentMethod;
  final String? paymentId;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OrderFirestore({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.paymentMethod,
    this.paymentId,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderFirestore.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final itemsData = data['items'] as List<dynamic>? ?? [];

    return OrderFirestore(
      id: doc.id,
      userId: data['userId'] ?? '',
      items: itemsData
          .map(
            (item) => CartItemFirestore(
              productId: item['productId'] ?? '',
              name: item['name'] ?? '',
              price: (item['price'] ?? 0).toDouble(),
              quantity: item['quantity'] ?? 1,
              imageUrl: item['imageUrl'] ?? '',
            ),
          )
          .toList(),
      total: (data['total'] ?? 0).toDouble(),
      paymentMethod: data['paymentMethod'] ?? '',
      paymentId: data['paymentId'],
      status: data['status'] ?? 'pending',
      createdAt: data['createdAt']?.toDate(),
      updatedAt: data['updatedAt']?.toDate(),
    );
  }
}
