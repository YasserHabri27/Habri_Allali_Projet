import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_datasource.dart';
import '../datasources/task_remote_datasource.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;
  final TaskLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  TaskRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Task>> createTask(Task task) async {
    if (await networkInfo.isConnected) {
      try {
        final taskModel = TaskModel.fromEntity(task);
        final createdTask = await remoteDataSource.createTask(taskModel);
        await localDataSource.cacheTask(createdTask);
        return Right(createdTask.toEntity());
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
  Future<Either<Failure, List<Task>>> getTasks() async {
    if (await networkInfo.isConnected) {
      try {
        final tasks = await remoteDataSource.getTasks();
        await localDataSource.cacheTasks(tasks);
        return Right(tasks.map((model) => model.toEntity()).toList());
      } on ServerException catch (e) {
        try {
          final cachedTasks = await localDataSource.getCachedTasks();
          return Right(cachedTasks.map((model) => model.toEntity()).toList());
        } on CacheException catch (cacheError) {
          return Left(CacheFailure(message: cacheError.message));
        }
      }
    } else {
      try {
        final cachedTasks = await localDataSource.getCachedTasks();
        return Right(cachedTasks.map((model) => model.toEntity()).toList());
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, Task>> getTaskById(String id) async {
    try {
      final cachedTask = await localDataSource.getCachedTaskById(id);
      if (cachedTask != null) {
        return Right(cachedTask.toEntity());
      }
      if (await networkInfo.isConnected) {
        try {
          final task = await remoteDataSource.getTaskById(id);
          await localDataSource.cacheTask(task);
          return Right(task.toEntity());
        } on ServerException catch (e) {
          return Left(ServerFailure(message: e.message));
        }
      } else {
        return Left(CacheFailure(message: 'Task not found in cache'));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Task>> updateTask(Task task) async {
    if (await networkInfo.isConnected) {
      try {
        final taskModel = TaskModel.fromEntity(task);
        final updatedTask = await remoteDataSource.updateTask(taskModel);
        await localDataSource.cacheTask(updatedTask);
        return Right(updatedTask.toEntity());
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
  Future<Either<Failure, void>> deleteTask(String id) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteTask(id);
        await localDataSource.deleteCachedTask(id);
        return const Right(null);
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
  Future<Either<Failure, List<Task>>> getTasksByProject(String projectId) async {
    if (await networkInfo.isConnected) {
      try {
        final tasks = await remoteDataSource.getTasksByProject(projectId);
        // Mettre en cache les tâches par projet
        for (final task in tasks) {
          await localDataSource.cacheTask(task);
        }
        return Right(tasks.map((model) => model.toEntity()).toList());
      } on ServerException catch (e) {
        try {
          final cachedTasks = await localDataSource.getCachedTasksByProject(projectId);
          return Right(cachedTasks.map((model) => model.toEntity()).toList());
        } on CacheException catch (cacheError) {
          return Left(CacheFailure(message: cacheError.message));
        }
      }
    } else {
      try {
        final cachedTasks = await localDataSource.getCachedTasksByProject(projectId);
        return Right(cachedTasks.map((model) => model.toEntity()).toList());
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, List<Task>>> getTasksByStatus(TaskStatus status) async {
    final result = await getTasks();
    return result.fold(
      (failure) => Left(failure),
      (tasks) {
        final filteredTasks = tasks.where((task) => task.status == status).toList();
        return Right(filteredTasks);
      },
    );
  }

  @override
  Future<Either<Failure, List<Task>>> getTasksByPriority(TaskPriority priority) async {
    final result = await getTasks();
    return result.fold(
      (failure) => Left(failure),
      (tasks) {
        final filteredTasks = tasks.where((task) => task.priority == priority).toList();
        return Right(filteredTasks);
      },
    );
  }

  @override
  Future<Either<Failure, List<Task>>> getOverdueTasks() async {
    final result = await getTasks();
    return result.fold(
      (failure) => Left(failure),
      (tasks) {
        final overdueTasks = tasks.where((task) => task.isOverdue).toList();
        return Right(overdueTasks);
      },
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getTaskStatistics(String projectId) async {
    final result = await getTasksByProject(projectId);
    
    return result.fold(
      (failure) => Left(failure),
      (tasks) {
        final totalTasks = tasks.length;
        final completedTasks = tasks.where((task) => task.status == TaskStatus.done).length;
        final inProgressTasks = tasks.where((task) => task.status == TaskStatus.inProgress).length;
        final todoTasks = tasks.where((task) => task.status == TaskStatus.todo).length;
        final highPriorityTasks = tasks.where((task) => task.priority == TaskPriority.high).length;
        final overdueTasks = tasks.where((task) => task.isOverdue).length;
        
        final progress = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0.0;
        
        return Right({
          'totalTasks': totalTasks,
          'completedTasks': completedTasks,
          'inProgressTasks': inProgressTasks,
          'todoTasks': todoTasks,
          'highPriorityTasks': highPriorityTasks,
          'overdueTasks': overdueTasks,
          'progress': progress,
          'projectId': projectId,
        });
      },
    );
  }

  @override
  Future<Either<Failure, void>> syncTasksWithProject(String projectId) async {
    // Cette méthode sert de point d'entrée pour la logique de synchronisation définie dans le UseCase correspondant
    // Pour l'instant, elle confirme simplement l'opération
    return const Right(null);
  }
}
