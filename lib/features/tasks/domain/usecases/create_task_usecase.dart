import 'package:dartz/dartz.dart' hide Task;
import '../../../../core/errors/failures.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class CreateTaskUseCase {
  final TaskRepository repository;
  CreateTaskUseCase(this.repository);
  
  Future<Either<Failure, Task>> execute(Task task) async {
    return await repository.createTask(task);
  }
}
