import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/task_repository.dart';

class DeleteTaskUseCase {
  final TaskRepository repository;
  DeleteTaskUseCase(this.repository);
  
  Future<Either<Failure, void>> execute(String id) async {
    return await repository.deleteTask(id);
  }
}
