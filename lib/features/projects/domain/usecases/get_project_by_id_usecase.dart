import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/project.dart';
import '../repositories/project_repository.dart';

class GetProjectByIdUseCase {
  final ProjectRepository repository;
  GetProjectByIdUseCase(this.repository);
  Future<Either<Failure, Project>> execute(String id) async {
    return await repository.getProjectById(id);
  }
}
