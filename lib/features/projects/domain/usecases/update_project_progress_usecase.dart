import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/project_repository.dart';

class UpdateProjectProgressUseCase {
  final ProjectRepository repository;
  UpdateProjectProgressUseCase(this.repository);
  Future<Either<Failure, void>> execute(String projectId, double progress) async {
    return await repository.updateProjectProgress(projectId, progress);
  }
}
