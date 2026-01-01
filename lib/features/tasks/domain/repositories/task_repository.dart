import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/task.dart';

abstract class TaskRepository {
  Future<Either<Failure, List<Task>>> getTasksByProject(String projectId);
  // Add other methods as needed later
}
