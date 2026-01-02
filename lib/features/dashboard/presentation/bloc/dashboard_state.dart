import 'package:equatable/equatable.dart';
import '../../../projects/domain/entities/project.dart';
import '../../../tasks/domain/entities/task.dart';

class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final List<Project> projects;
  final List<Task> recentTasks;
  final Map<String, dynamic> projectStatistics;
  final Map<String, dynamic> taskStatistics;

  const DashboardLoaded({
    required this.projects,
    required this.recentTasks,
    required this.projectStatistics,
    required this.taskStatistics,
  });

  @override
  List<Object> get props => [projects, recentTasks, projectStatistics, taskStatistics];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object> get props => [message];
}
