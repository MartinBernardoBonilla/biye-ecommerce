import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

// Abstract base class for all use cases.
abstract class Usecase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}
