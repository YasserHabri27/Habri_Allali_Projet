import 'package:equatable/equatable.dart';
import '../../domain/entities/task.dart';

abstract class TaskState extends Equatable {
  const TaskState();
  @override
  List<Object> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TasksLoaded extends TaskState {
  final List<Task> tasks;
  const TasksLoaded({required this.tasks});
  @override
  List<Object> get props => [tasks];
}

class TaskCreated extends TaskState {
  final Task task;
  const TaskCreated(this.task);
  @override
  List<Object> get props => [task];
}

class TaskUpdated extends TaskState {
  final Task task;
  const TaskUpdated(this.task);
  @override
  List<Object> get props => [task];
}

class TaskDeleted extends TaskState {
  final String taskId;
  const TaskDeleted(this.taskId);
  @override
  List<Object> get props => [taskId];
}

class TaskError extends TaskState {
  final String message;
  const TaskError(this.message);
  @override
  List<Object> get props => [message];
}

class TaskSyncedWithProject extends TaskState {
  final String projectId;
  const TaskSyncedWithProject(this.projectId);
  @override
  List<Object> get props => [projectId];
}
