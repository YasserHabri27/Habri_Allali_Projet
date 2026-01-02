import 'package:dartz/dartz.dart' hide Task;
import '../../../../core/errors/failures.dart';
import '../entities/task.dart';

abstract class TaskRepository {
  // Opérations CRUD standards
  Future<Either<Failure, Task>> createTask(Task task);
  Future<Either<Failure, List<Task>>> getTasks();
  Future<Either<Failure, Task>> getTaskById(String id);
  Future<Either<Failure, Task>> updateTask(Task task);
  Future<Either<Failure, void>> deleteTask(String id);
  
  // Méthodes spécifiques au flux de travail
  Future<Either<Failure, List<Task>>> getTasksByProject(String projectId);
  Future<Either<Failure, List<Task>>> getTasksByStatus(TaskStatus status);
  Future<Either<Failure, List<Task>>> getTasksByPriority(TaskPriority priority);
  Future<Either<Failure, List<Task>>> getOverdueTasks();
  
  // Méthodes nécessaires pour le calcul de la progression du projet
  Future<Either<Failure, Map<String, dynamic>>> getTaskStatistics(String projectId);
  
  // Méthodes de synchronisation
  Future<Either<Failure, void>> syncTasksWithProject(String projectId);
}
