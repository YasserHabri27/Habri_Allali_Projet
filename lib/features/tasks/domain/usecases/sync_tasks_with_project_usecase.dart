import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../projects/domain/usecases/calculate_project_progress_usecase.dart';
import '../../projects/domain/usecases/update_project_progress_usecase.dart';
import '../repositories/task_repository.dart';

class SyncTasksWithProjectUseCase {
  final TaskRepository taskRepository;
  final CalculateProjectProgressUseCase calculateProjectProgressUseCase;
  final UpdateProjectProgressUseCase updateProjectProgressUseCase;
  
  SyncTasksWithProjectUseCase({
    required this.taskRepository,
    required this.calculateProjectProgressUseCase,
    required this.updateProjectProgressUseCase,
  });
  
  Future<Either<Failure, void>> execute(String projectId) async {
    // 1. Obtenir les statistiques actuelles des tâches
    final statsResult = await taskRepository.getTaskStatistics(projectId);
    
    return await statsResult.fold(
      (failure) => Left(failure),
      (stats) async {
        // 2. Calculer le nouveau progrès du projet
        final progressResult = await calculateProjectProgressUseCase.execute(projectId);
        
        return await progressResult.fold(
          (failure) => Left(failure),
          (progress) async {
            // 3. Mettre à jour le progrès du projet
            return await updateProjectProgressUseCase.execute(projectId, progress);
          },
        );
      },
    );
  }
}
