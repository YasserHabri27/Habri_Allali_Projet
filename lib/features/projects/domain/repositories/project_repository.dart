import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/project.dart';

abstract class ProjectRepository {
  Future<Either<Failure, Project>> createProject(Project project);
  Future<Either<Failure, List<Project>>> getProjects();
  Future<Either<Failure, Project>> getProjectById(String id);
  Future<Either<Failure, Project>> updateProject(Project project);
  Future<Either<Failure, void>> deleteProject(String id);
  
  Future<Either<Failure, double>> calculateProjectProgress(String projectId);
  Future<Either<Failure, void>> updateProjectProgress(String projectId, double progress);
  
  Future<Either<Failure, List<Project>>> getProjectsByStatus(ProjectStatus status);
  Future<Either<Failure, Map<String, dynamic>>> getProjectStatistics();
}
