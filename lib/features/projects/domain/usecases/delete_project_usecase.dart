import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/project_repository.dart';

class DeleteProjectUseCase {
  final ProjectRepository repository;
  DeleteProjectUseCase(this.repository);
  Future<Either<Failure, void>> execute(String id) async {
    return await repository.deleteProject(id);
  }
}
