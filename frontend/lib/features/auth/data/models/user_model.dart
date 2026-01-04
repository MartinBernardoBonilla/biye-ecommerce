import '../../../cart/domain/entities/user.dart';

// El modelo de datos para el usuario, adaptado para las llamadas a la API.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
    );
  }
}
