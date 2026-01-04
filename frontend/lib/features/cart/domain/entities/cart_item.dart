// Este archivo define la estructura de datos que representa un artículo dentro del carrito.
// Es una entidad pura, sin lógica de negocio (solo datos).
class CartItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  // Añadimos la URL de la imagen y la descripción
  final String imageUrl;
  final String description;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl, // Ahora CartItem soporta imageUrl
    required this.description, // Ahora CartItem soporta description
  });

  // Método para crear una copia del CartItem con una nueva cantidad.
  CartItem copyWith({
    String? id,
    String? name,
    double? price,
    int? quantity,
    String? imageUrl,
    String? description,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
    );
  }

  // Opcional: Para facilitar la depuración
  @override
  String toString() {
    return 'CartItem(id: $id, name: $name, price: $price, quantity: $quantity, description: $description)';
  }
}
