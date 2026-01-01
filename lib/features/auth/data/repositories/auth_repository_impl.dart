import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';
import '../../../../core/errors/exceptions.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await remoteDataSource.login(email, password);
        await localDataSource.cacheUser(userModel);
        return Right(userModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, User>> register(String name, String email, String password) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await remoteDataSource.register(name, email, password);
        await localDataSource.cacheUser(userModel);
        return Right(userModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final user = await localDataSource.getCachedUser();
      if (user?.token != null) {
        await remoteDataSource.logout(user!.token!);
      }
      await localDataSource.clearCachedUser();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
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
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final hasUser = await localDataSource.hasCachedUser();
      return Right(hasUser);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }
}
