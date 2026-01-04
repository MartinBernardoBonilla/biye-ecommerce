import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

import '../../../../core/network/api_client.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String username, String email, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await apiClient.post('auth/login', {
        'email': email,
        'password': password,
      });
      return UserModel.fromJson(response);
    } catch (e) {
      throw ServerException(message: 'Error de conexión con el servidor: $e');
    }
  }

  @override
  Future<UserModel> register(
    String username,
    String email,
    String password,
  ) async {
    try {
      final response = await apiClient.post('auth/register', {
        'username': username,
        'email': email,
        'password': password,
      });
      return UserModel.fromJson(response);
    } catch (e) {
      throw ServerException(message: 'Error de conexión con el servidor: $e');
    }
  }
}
