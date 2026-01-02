import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/project_repository.dart';

class GetProjectStatisticsUseCase {
  final ProjectRepository repository;
  GetProjectStatisticsUseCase(this.repository);
  Future<Either<Failure, Map<String, dynamic>>> execute() async {
    return await repository.getProjectStatistics();
  }
}
