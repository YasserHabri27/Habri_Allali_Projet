import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import '../../../../core/errors/failures.dart';
import '../../../projects/domain/entities/project.dart';
import '../../../projects/domain/usecases/get_projects_usecase.dart';
import '../../../projects/domain/usecases/get_project_statistics_usecase.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/domain/usecases/get_tasks_usecase.dart';
import '../../../tasks/domain/usecases/get_task_statistics_usecase.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetProjectsUseCase getProjectsUseCase;
  final GetProjectStatisticsUseCase getProjectStatisticsUseCase;
  final GetTasksUseCase getTasksUseCase;
  final GetTaskStatisticsUseCase getTaskStatisticsUseCase;

  DashboardBloc({
    required this.getProjectsUseCase,
    required this.getProjectStatisticsUseCase,
    required this.getTasksUseCase,
    required this.getTaskStatisticsUseCase,
  }) : super(DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    final projectsResult = await getProjectsUseCase.execute();
    final statsResult = await getProjectStatisticsUseCase.execute();
    final tasksResult = await getTasksUseCase.execute();

    await _handleDashboardResults(
      projectsResult,
      statsResult,
      tasksResult,
      emit,
    );
  }

  Future<void> _handleDashboardResults(
    Either<Failure, List<Project>> projectsResult,
    Either<Failure, Map<String, dynamic>> statsResult,
    Either<Failure, List<Task>> tasksResult,
    Emitter<DashboardState> emit,
  ) async {
    projectsResult.fold(
      (failure) => emit(DashboardError(failure.message)),
      (projects) async {
        statsResult.fold(
          (failure) => emit(DashboardError(failure.message)),
          (projectStats) async {
            tasksResult.fold(
              (failure) => emit(DashboardError(failure.message)),
              (tasks) async {
                // Obtenir les statistiques des tâches
                final taskStatsResult = await _getOverallTaskStatistics(tasks);
                
                taskStatsResult.fold(
                  (failure) => emit(DashboardError(failure.message)),
                  (taskStats) {
                    // Trier les projets par avancement (du plus bas au plus haut)
                    final sortedProjects = List<Project>.from(projects)
                      ..sort((a, b) => a.progress.compareTo(b.progress));
                    
                    // Trier les tâches par date (les plus récentes d'abord)
                    final sortedTasks = List<Task>.from(tasks)
                      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
                    
                    emit(DashboardLoaded(
                      projects: sortedProjects,
                      recentTasks: sortedTasks.take(5).toList(),
                      projectStatistics: projectStats,
                      taskStatistics: taskStats,
                    ));
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Future<Either<Failure, Map<String, dynamic>>> _getOverallTaskStatistics(List<Task> tasks) async {
    try {
      final totalTasks = tasks.length;
      final completedTasks = tasks.where((t) => t.status == TaskStatus.done).length;
      final inProgressTasks = tasks.where((t) => t.status == TaskStatus.inProgress).length;
      final todoTasks = tasks.where((t) => t.status == TaskStatus.todo).length;
      final overdueTasks = tasks.where((t) => t.isOverdue).length;
      
      final overallProgress = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0.0;

      return Right({
        'totalTasks': totalTasks,
        'completedTasks': completedTasks,
        'inProgressTasks': inProgressTasks,
        'todoTasks': todoTasks,
        'overdueTasks': overdueTasks,
        'overallProgress': overallProgress,
      });
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to calculate task statistics: $e'));
    }
  }
}
