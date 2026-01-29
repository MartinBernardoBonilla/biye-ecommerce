import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String username;
  final String? token; // <--- Agregar esto

  const User({
    required this.id,
    required this.email,
    required this.username,
    this.token, // <--- Agregar esto
  });

  @override
  List<Object?> get props =>
      [id, email, username, token]; // <--- Actualizar props
}
