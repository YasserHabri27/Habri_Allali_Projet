import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/task_repository.dart';

class GetTaskStatisticsUseCase {
  final TaskRepository repository;
  GetTaskStatisticsUseCase(this.repository);
  
  Future<Either<Failure, Map<String, dynamic>>> execute(String projectId) async {
    return await repository.getTaskStatistics(projectId);
  }
}
