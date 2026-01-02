import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class IsAuthenticatedUseCase {
  final AuthRepository repository;

  IsAuthenticatedUseCase(this.repository);

  Future<Either<Failure, bool>> execute() async {
    return await repository.isAuthenticated();
  }
}
