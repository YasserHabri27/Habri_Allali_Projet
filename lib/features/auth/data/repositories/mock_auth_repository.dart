import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    // Simule une latence réseau
    await Future.delayed(const Duration(seconds: 1));
    
    // Toujours réussir le login pour la démo
    return Right(User(
      id: 'demo_user_id',
      name: 'Utilisateur Démo',
      email: email,
      token: 'fake_jwt_token_for_demo',
    ));
  }

  @override
  Future<Either<Failure, User>> register(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    return Right(User(
      id: 'demo_user_id',
      name: name,
      email: email,
      token: 'fake_jwt_token_for_demo',
    ));
  }

  @override
  Future<Either<Failure, void>> logout() async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    return const Right(User(
      id: 'demo_user_id',
      name: 'Utilisateur Démo',
      email: 'demo@pegasus.com',
      token: 'fake_jwt_token_for_demo',
    ));
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    return const Right(true);
  }
}
