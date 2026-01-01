import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class GetTasksByProjectUseCase {
  final TaskRepository repository;
  GetTasksByProjectUseCase(this.repository);
  
  Future<Either<Failure, List<Task>>> execute(String projectId) async {
    return await repository.getTasksByProject(projectId);
  }
}
