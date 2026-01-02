import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/project_local_datasource.dart';
import '../datasources/project_remote_datasource.dart';
import '../models/project_model.dart';
import '../../../../core/errors/exceptions.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectRemoteDataSource remoteDataSource;
  final ProjectLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ProjectRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Project>> createProject(Project project) async {
    if (await networkInfo.isConnected) {
      try {
        final projectModel = ProjectModel.fromEntity(project);
        final createdProject = await remoteDataSource.createProject(projectModel);
        await localDataSource.cacheProject(createdProject);
        return Right(createdProject.toEntity());
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
  Future<Either<Failure, List<Project>>> getProjects() async {
    // Vérification de la connectivité réseau
    if (await networkInfo.isConnected) {
      try {
        // En ligne : Nous récupérons les données depuis l'API distante
        final projects = await remoteDataSource.getProjects();
        // Stratégie de mise en cache : "Fresh Data First"
        // Nous mettons à jour le cache local immédiatement avec les nouvelles données
        await localDataSource.cacheProjects(projects);
        return Right(projects.map((model) => model.toEntity()).toList());
      } on ServerException catch (e) {
        // En cas d'erreur serveur, nous essayons de replier sur le cache local (Fallback)
        try {
          final cachedProjects = await localDataSource.getCachedProjects();
          return Right(cachedProjects.map((model) => model.toEntity()).toList());
        } on CacheException catch (cacheError) {
          return Left(CacheFailure(message: cacheError.message));
        }
      }
    } else {
      // Hors ligne : Nous servons les données depuis le cache local (Offline Mode)
      try {
        final cachedProjects = await localDataSource.getCachedProjects();
        return Right(cachedProjects.map((model) => model.toEntity()).toList());
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, Project>> getProjectById(String id) async {
    try {
      final cachedProject = await localDataSource.getCachedProjectById(id);
      if (cachedProject != null) {
        return Right(cachedProject.toEntity());
      }
      if (await networkInfo.isConnected) {
        try {
          final project = await remoteDataSource.getProjectById(id);
          await localDataSource.cacheProject(project);
          return Right(project.toEntity());
        } on ServerException catch (e) {
          return Left(ServerFailure(message: e.message));
        }
      } else {
        return Left(CacheFailure(message: 'Project not found in cache'));
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Project>> updateProject(Project project) async {
    if (await networkInfo.isConnected) {
      try {
        final projectModel = ProjectModel.fromEntity(project);
        final updatedProject = await remoteDataSource.updateProject(projectModel);
        await localDataSource.cacheProject(updatedProject);
        return Right(updatedProject.toEntity());
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
  Future<Either<Failure, void>> deleteProject(String id) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteProject(id);
        await localDataSource.deleteCachedProject(id);
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
  Future<Either<Failure, double>> calculateProjectProgress(String projectId) async {
    return Left(ServerFailure(message: 'Not implemented yet'));
  }

  @override
  Future<Either<Failure, void>> updateProjectProgress(String projectId, double progress) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.updateProjectProgress(projectId, progress);
        final cachedProject = await localDataSource.getCachedProjectById(projectId);
        if (cachedProject != null) {
          final updatedProject = ProjectModel(
            id: cachedProject.id,
            userId: cachedProject.userId,
            name: cachedProject.name,
            description: cachedProject.description,
            statusIndex: cachedProject.statusIndex,
            progress: progress,
            startDate: cachedProject.startDate,
            endDate: cachedProject.endDate,
            createdAt: cachedProject.createdAt,
            updatedAt: cachedProject.updatedAt,
            taskIds: cachedProject.taskIds,
            colorHex: cachedProject.colorHex,
          );
          await localDataSource.cacheProject(updatedProject);
        }
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
  Future<Either<Failure, List<Project>>> getProjectsByStatus(ProjectStatus status) async {
    final result = await getProjects();
    return result.fold(
      (failure) => Left(failure),
      (projects) {
        final filteredProjects = projects.where((project) => project.status == status).toList();
        return Right(filteredProjects);
      },
    );
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getProjectStatistics() async {
    final result = await getProjects();
    return result.fold(
      (failure) => Left(failure),
      (projects) {
        final totalProjects = projects.length;
        final completedProjects = projects.where((p) => p.status == ProjectStatus.done).length;
        final inProgressProjects = projects.where((p) => p.status == ProjectStatus.inProgress).length;
        final todoProjects = projects.where((p) => p.status == ProjectStatus.todo).length;
        final averageProgress = projects.isEmpty ? 0.0 : 
            projects.map((p) => p.progress).reduce((a, b) => a + b) / totalProjects;
        final overdueProjects = projects.where((p) => p.isOverdue).length;
        
        return Right({
          'totalProjects': totalProjects,
          'completedProjects': completedProjects,
          'inProgressProjects': inProgressProjects,
          'todoProjects': todoProjects,
          'averageProgress': averageProgress,
          'overdueProjects': overdueProjects,
        });
      },
    );
  }
}
