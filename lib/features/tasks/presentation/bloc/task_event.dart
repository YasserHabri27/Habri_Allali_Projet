import 'package:equatable/equatable.dart';
import '../../domain/entities/task.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();
  @override
  List<Object> get props => [];
}

class LoadTasks extends TaskEvent {}

class LoadTasksByProject extends TaskEvent {
  final String projectId;
  const LoadTasksByProject(this.projectId);
  @override
  List<Object> get props => [projectId];
}

class CreateTask extends TaskEvent {
  final Task task;
  const CreateTask(this.task);
  @override
  List<Object> get props => [task];
}

class UpdateTask extends TaskEvent {
  final Task task;
  const UpdateTask(this.task);
  @override
  List<Object> get props => [task];
}

class UpdateTaskStatus extends TaskEvent {
  final String taskId;
  final TaskStatus newStatus;
  const UpdateTaskStatus({required this.taskId, required this.newStatus});
  @override
  List<Object> get props => [taskId, newStatus];
}

class DeleteTask extends TaskEvent {
  final String id;
  const DeleteTask(this.id);
  @override
  List<Object> get props => [id];
}

class SyncTasksWithProject extends TaskEvent {
  final String projectId;
  const SyncTasksWithProject(this.projectId);
  @override
  List<Object> get props => [projectId];
}
