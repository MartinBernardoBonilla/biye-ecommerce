class ProductModel {
  final String id;
  final String user;
  final String name;
  final String description;
  final double price;
  final int countInStock;
  final String category;
  final ImageModel? image;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? brand;

  ProductModel({
    required this.id,
    required this.user,
    required this.name,
    required this.description,
    required this.price,
    required this.countInStock,
    required this.category,
    this.image,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.brand,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Extraer datos básicos
    final id = json['_id'] ?? '';
    final name = json['name'] ?? '';
    final category = json['category'] ?? '';

    // ============================================
    // ✅ LÓGICA CORREGIDA PARA IMÁGENES
    // ============================================
    ImageModel? image;

    if (json['image'] != null && json['image'] is Map<String, dynamic>) {
      final imageData = json['image'] as Map<String, dynamic>;

      // Verificar si tiene url
      if (imageData['url'] != null && (imageData['url'] as String).isNotEmpty) {
        image = ImageModel.fromJson(imageData);
      }
    }

    return ProductModel(
      id: id,
      user: json['user'] is String
          ? json['user']
          : (json['user'] is Map ? (json['user']?['_id'] ?? '') : ''),
      name: name,
      description: json['description'] ?? '',
      price: (json['price'] is int
          ? (json['price'] as int).toDouble()
          : (json['price'] is double ? json['price'] : 0.0)),
      countInStock: json['countInStock'] ?? 0,
      category: category,
      image: image,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      brand: json['brand'],
    );
  }

  // Método helper privado para crear imagen placeholder
  // ⚠️ DEPRECADO: No usar - El backend siempre provee imágenes reales
  /*
  static ImageModel _createPlaceholderImage(
      String id, String name, String category) {
    // Usar picsum.photos para imágenes aleatorias
    final seed = id.hashCode.abs() % 1000;
    return ImageModel(
      url: 'https://picsum.photos/seed/$seed/400/300',
      publicId: 'placeholder_$id',
    );
  }
  */

  // Método helper privado para obtener color según categoría
  // ⚠️ DEPRECADO: No se usa actualmente
  /*
  static String _getColorForCategory(String category) {
    final categoryMap = {
      'Software': '4CAF50', // Verde
      'software': '4CAF50',
      'Servicios': '2196F3', // Azul
      'servicios': '2196F3',
      'Servicio': '2196F3',
      'servicio': '2196F3',
      'Diseño': '9C27B0', // Púrpura
      'diseño': '9C27B0',
      'design': '9C27B0',
      'Design': '9C27B0,
      'Plantilla': 'FF9800', // Naranja
      'plantilla': 'FF9800',
      'Template': 'FF9800',
      'template': 'FF9800',
      'General': '607D8B', // Gris
      'general': '607D8B',
    };

    return categoryMap[category] ?? '607D8B'; // Gris por defecto
  }
  */

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user,
      'name': name,
      'description': description,
      'price': price,
      'countInStock': countInStock,
      'category': category,
      'image': image?.toJson(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'brand': brand,
    };
  }

  ProductModel copyWith({
    String? id,
    String? user,
    String? name,
    String? description,
    double? price,
    int? countInStock,
    String? category,
    ImageModel? image,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? brand,
  }) {
    return ProductModel(
      id: id ?? this.id,
      user: user ?? this.user,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      countInStock: countInStock ?? this.countInStock,
      category: category ?? this.category,
      image: image ?? this.image,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      brand: brand ?? this.brand,
    );
  }

  @override
  String toString() {
    return 'ProductModel(id: $id, name: $name, price: $price)';
  }
}

class ImageModel {
  final String url;
  final String publicId;

  ImageModel({required this.url, required this.publicId});

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      url: json['url'] ?? '',
      publicId: json['public_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'url': url, 'public_id': publicId};
  }

  // AÑADE ESTE MÉTODO copyWith:
  ImageModel copyWith({String? url, String? publicId}) {
    return ImageModel(
      url: url ?? this.url,
      publicId: publicId ?? this.publicId,
    );
  }

  @override
  String toString() {
    return 'ImageModel(url: $url, publicId: $publicId)';
  }
}
