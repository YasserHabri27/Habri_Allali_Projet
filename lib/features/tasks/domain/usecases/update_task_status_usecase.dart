import 'package:dartz/dartz.dart' hide Task;
import '../../../../core/errors/failures.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class UpdateTaskStatusUseCase {
  final TaskRepository repository;
  UpdateTaskStatusUseCase(this.repository);
  
  Future<Either<Failure, Task>> execute(String taskId, TaskStatus newStatus) async {
    final result = await repository.getTaskById(taskId);
    
    return await result.fold(
      (failure) => Left(failure),
      (task) async {
        final updatedTask = task.copyWith(
          status: newStatus,
          completedAt: newStatus == TaskStatus.done ? DateTime.now() : null,
          updatedAt: DateTime.now(),
        );
        return await repository.updateTask(updatedTask);
      },
    );
  }
}
