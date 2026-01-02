import 'package:dartz/dartz.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/errors/failures.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/user_model.dart';

/// Repository d'authentification simulé pour les tests et démo
/// Ne dépend pas du réseau, fonctionne 100% localement
class MockAuthRepository implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  MockAuthRepository({required this.localDataSource});

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simule le délai réseau
    
    try {
      // Accepter n'importe quel email/password pour la démo
      final userModel = UserModel(
        id: 'mock-user-${email.hashCode}',
        name: email.split('@').first,
        email: email,
        token: 'mock-token-${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
      );
      
      await localDataSource.cacheUser(userModel);
      return Right(userModel.toEntity());
    } catch (e) {
      return Left(CacheFailure(message: 'Login failed: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> register(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simule le délai réseau
    
    try {
      final userModel = UserModel(
        id: 'mock-user-${email.hashCode}',
        name: name,
        email: email,
        token: 'mock-token-${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
      );
      
      await localDataSource.cacheUser(userModel);
      return Right(userModel.toEntity());
    } catch (e) {
      return Left(CacheFailure(message: 'Registration failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearCachedUser();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Logout failed: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final userModel = await localDataSource.getCachedUser();
      if (userModel != null) {
        return Right(userModel.toEntity());
      } else {
        return Left(CacheFailure(message: 'No user found'));
      }
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final hasUser = await localDataSource.hasCachedUser();
      return Right(hasUser);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
