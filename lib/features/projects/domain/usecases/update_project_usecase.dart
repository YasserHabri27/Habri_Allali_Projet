import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/project.dart';
import '../repositories/project_repository.dart';

class UpdateProjectUseCase {
  final ProjectRepository repository;
  UpdateProjectUseCase(this.repository);
  Future<Either<Failure, Project>> execute(Project project) async {
    return await repository.updateProject(project);
  }
}
