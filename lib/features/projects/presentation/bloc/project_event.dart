import 'package:equatable/equatable.dart';
import '../../domain/entities/project.dart';

abstract class ProjectEvent extends Equatable {
  const ProjectEvent();
  @override
  List<Object> get props => [];
}

class LoadProjects extends ProjectEvent {}
class LoadProjectById extends ProjectEvent {
  final String id;
  const LoadProjectById(this.id);
  @override
  List<Object> get props => [id];
}
class CreateProject extends ProjectEvent {
  final Project project;
  const CreateProject(this.project);
  @override
  List<Object> get props => [project];
}
class UpdateProject extends ProjectEvent {
  final Project project;
  const UpdateProject(this.project);
  @override
  List<Object> get props => [project];
}
class DeleteProject extends ProjectEvent {
  final String id;
  const DeleteProject(this.id);
  @override
  List<Object> get props => [id];
}
class UpdateProjectProgress extends ProjectEvent {
  final String projectId;
  final double progress;
  const UpdateProjectProgress({required this.projectId, required this.progress});
  @override
  List<Object> get props => [projectId, progress];
}
class LoadProjectStatistics extends ProjectEvent {}
class FilterProjectsByStatus extends ProjectEvent {
  final String status;
  const FilterProjectsByStatus(this.status);
  @override
  List<Object> get props => [status];
}
