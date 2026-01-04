import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

// Caso de uso para iniciar sesión de un usuario.
class LoginUser extends Usecase<User, LoginParams> {
  final AuthRepository repository;

  LoginUser({required this.repository});

  @override
  Future<Either<Failure, User>> call(LoginParams params) async {
    return await repository.login(params.email, params.password);
  }
}

// Parámetros necesarios para el caso de uso.
class LoginParams {
  final String email;
  final String password;

  LoginParams({required this.email, required this.password});
}
