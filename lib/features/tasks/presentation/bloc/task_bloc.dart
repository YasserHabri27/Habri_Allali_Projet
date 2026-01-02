```dart
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/create_task_usecase.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/usecases/get_tasks_by_project_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';
import '../../domain/usecases/update_task_status_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../../projects/domain/usecases/recalculate_project_progress_usecase.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasksUseCase getTasksUseCase;
  final GetTasksByProjectUseCase getTasksByProjectUseCase;
  final CreateTaskUseCase createTaskUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final UpdateTaskStatusUseCase updateTaskStatusUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;
  final RecalculateProjectProgressUseCase recalculateProjectProgressUseCase;

  TaskBloc({
    required this.getTasksUseCase,
    required this.getTasksByProjectUseCase,
    required this.createTaskUseCase,
    required this.updateTaskUseCase,
    required this.updateTaskStatusUseCase,
    required this.deleteTaskUseCase,
    required this.recalculateProjectProgressUseCase,
  }) : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<LoadTasksByProject>(_onLoadTasksByProject);
    on<CreateTask>(_onCreateTask);
    on<UpdateTask>(_onUpdateTask);
    on<UpdateTaskStatus>(_onUpdateTaskStatus);
    on<DeleteTask>(_onDeleteTask);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    final result = await getTasksUseCase.execute();
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (tasks) => emit(TasksLoaded(tasks: tasks)),
    );
  }

  Future<void> _onLoadTasksByProject(LoadTasksByProject event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    final result = await getTasksByProjectUseCase.execute(event.projectId);
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (tasks) => emit(TasksLoaded(tasks: tasks)),
    );
  }

  Future<void> _onCreateTask(CreateTask event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    final result = await createTaskUseCase.execute(event.task);
    await result.fold(
      (failure) async => emit(TaskError(failure.message)),
      (task) async {
        emit(TaskCreated(task));
        // Nous recalculons automatiquement la progression du projet
        await recalculateProjectProgressUseCase.execute(task.projectId);
      },
    );
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    final result = await updateTaskUseCase.execute(event.task);
    await result.fold(
      (failure) async => emit(TaskError(failure.message)),
      (task) async {
        emit(TaskUpdated(task));
        // Nous recalculons automatiquement la progression du projet
        await recalculateProjectProgressUseCase.execute(task.projectId);
      },
    );
  }

  Future<void> _onUpdateTaskStatus(UpdateTaskStatus event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    final result = await updateTaskStatusUseCase.execute(event.taskId, event.newStatus);
    await result.fold(
      (failure) async => emit(TaskError(failure.message)),
      (task) async {
        emit(TaskUpdated(task));
        // Nous recalculons automatiquement la progression du projet
        await recalculateProjectProgressUseCase.execute(task.projectId);
        // Nous rechargeons la liste des tâches pour refléter le changement
        add(LoadTasks());
      },
    );
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    final result = await deleteTaskUseCase.execute(event.id);
    result.fold(
      (failure) => emit(TaskError(failure.message)),
      (_) => emit(TaskDeleted(event.id)),
    );
  }

}
