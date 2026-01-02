import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../tasks/domain/repositories/task_repository.dart';
import '../../../tasks/domain/entities/task.dart';
import '../repositories/project_repository.dart';

class RecalculateProjectProgressUseCase {
  final TaskRepository taskRepository;
  final ProjectRepository projectRepository;

  RecalculateProjectProgressUseCase({
    required this.taskRepository,
    required this.projectRepository,
  });

  Future<Either<Failure, double>> execute(String projectId) async {
    // Nous récupérons toutes les tâches du projet
    final tasksResult = await taskRepository.getTasksByProject(projectId);
    
    return await tasksResult.fold(
      (failure) => Left(failure),
      (tasks) async {
        if (tasks.isEmpty) {
          return const Right(0.0);
        }
        
        // Nous calculons le pourcentage de tâches terminées
        final completedTasks = tasks.where((task) => task.status == TaskStatus.done).length;
        final progress = (completedTasks / tasks.length) * 100;
        
        // Nous mettons à jour la progression du projet
        final updateResult = await projectRepository.updateProjectProgress(projectId, progress);
        
        return updateResult.fold(
          (failure) => Left(failure),
          (_) => Right(progress),
        );
      },
    );
  }
}
