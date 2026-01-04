import 'package:equatable/equatable.dart';

// Las excepciones son errores que ocurren en la capa de datos.
class ServerException implements Exception {
  final String message;
  const ServerException({required this.message});
}

class CacheException implements Exception {}

// Los fallos son errores que ocurren en la capa de dominio.
abstract class Failure extends Equatable {
  const Failure();
}

class ServerFailure extends Failure {
  final String message;

  const ServerFailure({required this.message});

  @override
  List<Object> get props => [message];
}

class CacheFailure extends Failure {
  @override
  List<Object> get props => [];
}
