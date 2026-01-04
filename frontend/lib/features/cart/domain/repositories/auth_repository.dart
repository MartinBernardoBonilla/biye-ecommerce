import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

/// Contrato de autenticación.
/// Define los métodos que deben implementar los repositorios.
abstract class AuthRepository {
  /// Inicia sesión con email y password.
  /// Devuelve [User] si tiene éxito o [Failure] en caso de error.
  Future<Either<Failure, User>> login(String email, String password);

  /// Registra un nuevo usuario con username, email y password.
  /// Devuelve [User] si tiene éxito o [Failure] en caso de error.
  Future<Either<Failure, User>> register(
    String username,
    String email,
    String password,
  );
}
