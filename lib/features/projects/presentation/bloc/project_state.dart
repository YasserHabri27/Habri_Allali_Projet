import 'package:equatable/equatable.dart';
import '../../domain/entities/project.dart';

abstract class ProjectState extends Equatable {
  const ProjectState();
  @override
  List<Object> get props => [];
}

class ProjectInitial extends ProjectState {}
class ProjectLoading extends ProjectState {}
class ProjectsLoaded extends ProjectState {
  final List<Project> projects;
  final Map<String, dynamic>? statistics;
  const ProjectsLoaded({required this.projects, this.statistics});
  @override
  List<Object> get props => [projects, statistics ?? {}];
}
class ProjectLoaded extends ProjectState {
  final Project project;
  const ProjectLoaded(this.project);
  @override
  List<Object> get props => [project];
}
class ProjectCreated extends ProjectState {
  final Project project;
  const ProjectCreated(this.project);
  @override
  List<Object> get props => [project];
}
class ProjectUpdated extends ProjectState {
  final Project project;
  const ProjectUpdated(this.project);
  @override
  List<Object> get props => [project];
}
class ProjectDeleted extends ProjectState {
  final String projectId;
  const ProjectDeleted(this.projectId);
  @override
  List<Object> get props => [projectId];
}
class ProjectError extends ProjectState {
  final String message;
  const ProjectError(this.message);
  @override
  List<Object> get props => [message];
}
class ProjectStatisticsLoaded extends ProjectState {
  final Map<String, dynamic> statistics;
  const ProjectStatisticsLoaded(this.statistics);
  @override
  List<Object> get props => [statistics];
}
