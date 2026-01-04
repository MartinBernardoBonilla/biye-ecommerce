import '../../../cart/domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart' as ex;
import '../../../../core/errors/failures.dart' as fl;
import '../../../cart/domain/entities/user.dart';

/// Implementación del repositorio de autenticación.
/// Llama al [AuthRemoteDataSource] para login y registro.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<fl.Failure, User>> login(String email, String password) async {
    try {
      final UserModel userModel = await remoteDataSource.login(email, password);
      return Right(userModel);
    } on ex.ServerException catch (e) {
      return Left(fl.ServerFailure(message: e.message));
    } on Exception catch (e) {
      return Left(fl.ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<fl.Failure, User>> register(
    String username,
    String email,
    String password,
  ) async {
    try {
      final UserModel userModel = await remoteDataSource.register(
        username,
        email,
        password,
      );
      return Right(userModel);
    } on ex.ServerException catch (e) {
      return Left(fl.ServerFailure(message: e.message));
    } on Exception catch (e) {
      return Left(fl.ServerFailure(message: e.toString()));
    }
  }
}
