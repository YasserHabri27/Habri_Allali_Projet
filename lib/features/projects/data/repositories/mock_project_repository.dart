import 'package:dartz/dartz.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../../../../core/errors/failures.dart';

class MockProjectRepository implements ProjectRepository {
  final List<Project> _mockProjects = [
    Project(
      id: '1',
      userId: 'mock-user',
      name: 'Application Mobile Pegasus',
      description: 'Développement de l\'application de gestion de projets',
      status: ProjectStatus.inProgress,
      progress: 65.0,
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      endDate: DateTime.now().add(const Duration(days: 60)),
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
      taskIds: ['1', '2', '3'],
      colorHex: '#6366F1',
    ),
    Project(
      id: '2',
      userId: 'mock-user',
      name: 'Site Web E-commerce',
      description: 'Plateforme de vente en ligne moderne',
      status: ProjectStatus.planning,
      progress: 15.0,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 90)),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      taskIds: ['4'],
      colorHex: '#EC4899',
    ),
    Project(
      id: '3',
      userId: 'mock-user',
      name: 'Migration Cloud AWS',
      description: 'Migration de l\'infrastructure vers AWS',
      status: ProjectStatus.completed,
      progress: 100.0,
      startDate: DateTime.now().subtract(const Duration(days: 60)),
      endDate: DateTime.now().subtract(const Duration(days: 5)),
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      taskIds: ['5', '6'],
      colorHex: '#10B981',
    ),
  ];

  @override
  Future<Either<Failure, List<Project>>> getProjects() async {
    await Future.delayed(const Duration(milliseconds: 200)); // Simulate network
    return Right(_mockProjects);
  }

  @override
  Future<Either<Failure, Project>> getProjectById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      final project = _mockProjects.firstWhere((p) => p.id == id);
      return Right(project);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Project>> createProject(Project project) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockProjects.add(project);
    return Right(project);
  }

  @override
  Future<Either<Failure, Project>> updateProject(Project project) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _mockProjects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      _mockProjects[index] = project;
      return Right(project);
    }
    return Left(ServerFailure());
  }

  @override
  Future<Either<Failure, void>> deleteProject(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mockProjects.removeWhere((p) => p.id == id);
    return const Right(null);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getProjectStatistics() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return Right({
      'totalProjects': _mockProjects.length,
      'completedProjects': _mockProjects.where((p) => p.status == ProjectStatus.completed).length,
      'inProgressProjects': _mockProjects.where((p) => p.status == ProjectStatus.inProgress).length,
      'averageProgress': _mockProjects.isEmpty 
        ? 0.0 
        : _mockProjects.map((p) => p.progress).reduce((a, b) => a + b) / _mockProjects.length,
    });
  }

  @override
  Future<Either<Failure, void>> updateProjectProgress(String projectId, double progress) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _mockProjects.indexWhere((p) => p.id == projectId);
    if (index != -1) {
      final project = _mockProjects[index];
      _mockProjects[index] = Project(
        id: project.id,
        userId: project.userId,
        name: project.name,
        description: project.description,
        status: project.status,
        progress: progress,
        startDate: project.startDate,
        endDate: project.endDate,
        createdAt: project.createdAt,
        updatedAt: DateTime.now(),
        taskIds: project.taskIds,
        colorHex: project.colorHex,
      );
      return const Right(null);
    }
    return Left(ServerFailure());
  }
}
