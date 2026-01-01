import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../tasks/domain/entities/task.dart';
import '../../tasks/domain/repositories/task_repository.dart';

class CalculateProjectProgressUseCase {
  // Ce cas d'utilisation dépend du Repository des tâches pour calculer la progression.
  // La progression est calculée en fonction du rapport entre les tâches terminées et le total des tâches.
  
  final TaskRepository taskRepository;
  CalculateProjectProgressUseCase(this.taskRepository);

  Future<Either<Failure, double>> execute(String projectId) async {
    final result = await taskRepository.getTasksByProject(projectId);
    
    return result.fold(
      (failure) => Left(failure),
      (tasks) {
        if (tasks.isEmpty) return const Right(0.0);
        final completedTasks = tasks.where((task) => task.status == TaskStatus.done).length;
        final progress = (completedTasks / tasks.length) * 100;
        return Right(progress);
      },
    );
  }
}
