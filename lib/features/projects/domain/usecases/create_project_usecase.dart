import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/project.dart';
import '../repositories/project_repository.dart';

class CreateProjectUseCase {
  final ProjectRepository repository;
  CreateProjectUseCase(this.repository);
  Future<Either<Failure, Project>> execute(Project project) async {
    return await repository.createProject(project);
  }
}
