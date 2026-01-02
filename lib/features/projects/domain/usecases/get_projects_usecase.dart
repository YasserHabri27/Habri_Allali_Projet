import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/project.dart';
import '../repositories/project_repository.dart';

class GetProjectsUseCase {
  final ProjectRepository repository;
  GetProjectsUseCase(this.repository);
  Future<Either<Failure, List<Project>>> execute() async {
    return await repository.getProjects();
  }
}
