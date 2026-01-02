import 'package:dartz/dartz.dart' hide Task;
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../../../../core/errors/failures.dart';

class MockTaskRepository implements TaskRepository {
  final List<Task> _mockTasks = [
    Task(
      id: '1',
      projectId: '1',
      title: 'Concevoir l\'architecture de l\'application',
      description: 'Définir la structure Clean Architecture',
      priority: TaskPriority.high,
      status: TaskStatus.done,
      dueDate: DateTime.now().subtract(const Duration(days: 20)),
      completedAt: DateTime.now().subtract(const Duration(days: 18)),
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
      updatedAt: DateTime.now().subtract(const Duration(days: 18)),
    ),
    Task(
      id: '2',
      projectId: '1',
      title: 'Implémenter le module Auth',
      description: 'Login, Register, Logout avec BLoC',
      priority: TaskPriority.high,
      status: TaskStatus.done,
      dueDate: DateTime.now().subtract(const Duration(days: 10)),
      completedAt: DateTime.now().subtract(const Duration(days: 12)),
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now().subtract(const Duration(days: 12)),
    ),
    Task(
      id: '3',
      projectId: '1',
      title: 'Créer l\'interface Dashboard',
      description: 'Design moderne avec glassmorphism',
      priority: TaskPriority.medium,
      status: TaskStatus.inProgress,
      dueDate: DateTime.now().add(const Duration(days: 5)),
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now(),
    ),
    Task(
      id: '4',
      projectId: '2',
      title: 'Setup du projet e-commerce',
      description: 'Initialiser le repository et dépendances',
      priority: TaskPriority.high,
      status: TaskStatus.todo,
      dueDate: DateTime.now().add(const Duration(days: 3)),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Task(
      id: '5',
      projectId: '3',
      title: 'Configuration AWS',
      description: 'Setup EC2, RDS, S3',
      priority: TaskPriority.high,
      status: TaskStatus.done,
      dueDate: DateTime.now().subtract(const Duration(days: 30)),
      completedAt: DateTime.now().subtract(const Duration(days: 28)),
      createdAt: DateTime.now().subtract(const Duration(days: 35)),
      updatedAt: DateTime.now().subtract(const Duration(days: 28)),
    ),
    Task(
      id: '6',
      projectId: '3',
      title: 'Migration de la base de données',
      description: 'Migrer PostgreSQL vers RDS',
      priority: TaskPriority.high,
      status: TaskStatus.done,
      dueDate: DateTime.now().subtract(const Duration(days: 15)),
      completedAt: DateTime.now().subtract(const Duration(days: 17)),
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 17)),
    ),
  ];

  @override
  Future<Either<Failure, List<Task>>> getTasks() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return Right(_mockTasks);
  }

  @override
  Future<Either<Failure, List<Task>>> getTasksByProject(String projectId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return Right(_mockTasks.where((t) => t.projectId == projectId).toList());
  }

  @override
  Future<Either<Failure, Task>> getTaskById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      final task = _mockTasks.firstWhere((t) => t.id == id);
      return Right(task);
    } catch (e) {
      return Left(ServerFailure(message: 'Task not found'));
    }
  }

  @override
  Future<Either<Failure, Task>> createTask(Task task) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mockTasks.add(task);
    return Right(task);
  }

  @override
  Future<Either<Failure, Task>> updateTask(Task task) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _mockTasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _mockTasks[index] = task;
      return Right(task);
    }
    return Left(ServerFailure(message: 'Task not found'));
  }

  @override
  Future<Either<Failure, void>> deleteTask(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _mockTasks.removeWhere((t) => t.id == id);
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<Task>>> getTasksByStatus(TaskStatus status) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return Right(_mockTasks.where((t) => t.status == status).toList());
  }

  @override
  Future<Either<Failure, List<Task>>> getTasksByPriority(TaskPriority priority) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return Right(_mockTasks.where((t) => t.priority == priority).toList());
  }

  @override
  Future<Either<Failure, List<Task>>> getOverdueTasks() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return Right(_mockTasks.where((t) => t.isOverdue && t.status != TaskStatus.done).toList());
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getTaskStatistics(String projectId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final projectTasks = _mockTasks.where((t) => t.projectId == projectId).toList();
    final completedTasks = projectTasks.where((t) => t.status == TaskStatus.done).length;
    
    return Right({
      'totalTasks': projectTasks.length,
      'completedTasks': completedTasks,
      'inProgressTasks': projectTasks.where((t) => t.status == TaskStatus.inProgress).length,
      'todoTasks': projectTasks.where((t) => t.status == TaskStatus.todo).length,
      'completionRate': projectTasks.isEmpty ? 0.0 : (completedTasks / projectTasks.length) * 100,
    });
  }

  @override
  Future<Either<Failure, void>> syncTasksWithProject(String projectId) async {
    // Dans une vraie implémentation, cela pourrait synchroniser avec le backend
    await Future.delayed(const Duration(milliseconds: 100));
    return const Right(null);
  }
}
