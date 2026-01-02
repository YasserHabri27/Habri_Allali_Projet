import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/project.dart';
import '../../domain/usecases/create_project_usecase.dart';
import '../../domain/usecases/get_projects_usecase.dart';
import '../../domain/usecases/get_project_by_id_usecase.dart';
import '../../domain/usecases/update_project_usecase.dart';
import '../../domain/usecases/delete_project_usecase.dart';
import '../../domain/usecases/get_project_statistics_usecase.dart';
import '../../domain/usecases/update_project_progress_usecase.dart';
import 'project_event.dart';
import 'project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final GetProjectsUseCase getProjectsUseCase;
  final GetProjectByIdUseCase getProjectByIdUseCase;
  final CreateProjectUseCase createProjectUseCase;
  final UpdateProjectUseCase updateProjectUseCase;
  final DeleteProjectUseCase deleteProjectUseCase;
  final GetProjectStatisticsUseCase getProjectStatisticsUseCase;
  final UpdateProjectProgressUseCase updateProjectProgressUseCase;

  ProjectBloc({
    required this.getProjectsUseCase,
    required this.getProjectByIdUseCase,
    required this.createProjectUseCase,
    required this.updateProjectUseCase,
    required this.deleteProjectUseCase,
    required this.getProjectStatisticsUseCase,
    required this.updateProjectProgressUseCase,
  }) : super(ProjectInitial()) {
    on<LoadProjects>(_onLoadProjects);
    on<LoadProjectById>(_onLoadProjectById);
    on<CreateProject>(_onCreateProject);
    on<UpdateProject>(_onUpdateProject);
    on<DeleteProject>(_onDeleteProject);
    on<UpdateProjectProgress>(_onUpdateProjectProgress);
    on<LoadProjectStatistics>(_onLoadProjectStatistics);
    on<FilterProjectsByStatus>(_onFilterProjectsByStatus);
  }

  Future<void> _onLoadProjects(LoadProjects event, Emitter<ProjectState> emit) async {
    emit(ProjectLoading());
    final result = await getProjectsUseCase.execute();
    result.fold(
      (failure) => emit(ProjectError(failure.message)),
      (projects) async {
        final statsResult = await getProjectStatisticsUseCase.execute();
        statsResult.fold(
          (failure) => emit(ProjectsLoaded(projects: projects)),
          (statistics) => emit(ProjectsLoaded(projects: projects, statistics: statistics)),
        );
      },
    );
  }

  Future<void> _onLoadProjectById(LoadProjectById event, Emitter<ProjectState> emit) async {
    emit(ProjectLoading());
    final result = await getProjectByIdUseCase.execute(event.id);
    result.fold(
      (failure) => emit(ProjectError(failure.message)),
      (project) => emit(ProjectLoaded(project)),
    );
  }

  Future<void> _onCreateProject(CreateProject event, Emitter<ProjectState> emit) async {
    emit(ProjectLoading());
    final result = await createProjectUseCase.execute(event.project);
    result.fold(
      (failure) => emit(ProjectError(failure.message)),
      (project) {
        emit(ProjectCreated(project));
        add(LoadProjects());
      },
    );
  }

  Future<void> _onUpdateProject(UpdateProject event, Emitter<ProjectState> emit) async {
    emit(ProjectLoading());
    final result = await updateProjectUseCase.execute(event.project);
    result.fold(
      (failure) => emit(ProjectError(failure.message)),
      (project) {
        emit(ProjectUpdated(project));
        add(LoadProjects());
      },
    );
  }

  Future<void> _onDeleteProject(DeleteProject event, Emitter<ProjectState> emit) async {
    emit(ProjectLoading());
    final result = await deleteProjectUseCase.execute(event.id);
    result.fold(
      (failure) => emit(ProjectError(failure.message)),
      (_) {
        emit(ProjectDeleted(event.id));
        add(LoadProjects());
      },
    );
  }

  Future<void> _onUpdateProjectProgress(UpdateProjectProgress event, Emitter<ProjectState> emit) async {
    final result = await updateProjectProgressUseCase.execute(event.projectId, event.progress);
    result.fold(
      (failure) => emit(ProjectError(failure.message)),
      (_) => add(LoadProjects()),
    );
  }

  Future<void> _onLoadProjectStatistics(LoadProjectStatistics event, Emitter<ProjectState> emit) async {
    emit(ProjectLoading());
    final result = await getProjectStatisticsUseCase.execute();
    result.fold(
      (failure) => emit(ProjectError(failure.message)),
      (statistics) => emit(ProjectStatisticsLoaded(statistics)),
    );
  }

  Future<void> _onFilterProjectsByStatus(FilterProjectsByStatus event, Emitter<ProjectState> emit) async {
    emit(ProjectLoading());
    final result = await getProjectsUseCase.execute();
    result.fold(
      (failure) => emit(ProjectError(failure.message)),
      (projects) {
        if (event.status == 'all') {
          emit(ProjectsLoaded(projects: projects));
        } else {
          final filteredProjects = projects.where((project) {
            return project.status.name == event.status;
          }).toList();
          emit(ProjectsLoaded(projects: filteredProjects));
        }
      },
    );
  }
}
