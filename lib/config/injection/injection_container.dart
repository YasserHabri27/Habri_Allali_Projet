import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_client.dart';
import '../../core/network/network_info.dart';
import '../../core/storage/hive_service.dart';
import '../../core/storage/preferences_service.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/data/services/token_service.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/is_authenticated_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/projects/data/datasources/project_local_datasource.dart';
import '../../features/projects/data/datasources/project_remote_datasource.dart';
import '../../features/projects/data/repositories/project_repository_impl.dart';
import '../../features/projects/domain/repositories/project_repository.dart';
import '../../features/projects/domain/usecases/calculate_project_progress_usecase.dart';
import '../../features/projects/domain/usecases/create_project_usecase.dart';
import '../../features/projects/domain/usecases/delete_project_usecase.dart';
import '../../features/projects/domain/usecases/get_project_by_id_usecase.dart';
import '../../features/projects/domain/usecases/get_project_statistics_usecase.dart';
import '../../features/projects/domain/usecases/get_projects_usecase.dart';
import '../../features/projects/domain/usecases/update_project_progress_usecase.dart';
import '../../features/projects/domain/usecases/update_project_usecase.dart';
import '../../features/projects/presentation/bloc/project_bloc.dart';

import '../../features/tasks/data/datasources/task_local_datasource.dart';
import '../../features/tasks/data/datasources/task_remote_datasource.dart';
import '../../features/tasks/data/repositories/task_repository_impl.dart';
import '../../features/tasks/domain/repositories/task_repository.dart';
import '../../features/tasks/domain/usecases/create_task_usecase.dart';
import '../../features/tasks/domain/usecases/delete_task_usecase.dart';
import '../../features/tasks/domain/usecases/get_task_statistics_usecase.dart';
import '../../features/tasks/domain/usecases/get_tasks_by_project_usecase.dart';
import '../../features/tasks/domain/usecases/get_tasks_usecase.dart';
import '../../features/tasks/domain/usecases/sync_tasks_with_project_usecase.dart';
import '../../features/tasks/domain/usecases/update_task_status_usecase.dart';
import '../../features/tasks/domain/usecases/update_task_usecase.dart';
import '../../features/tasks/presentation/bloc/task_bloc.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  //! External
  // Nous enregistrons les dépendances externes tierces
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);
  // Nous utilisons LazySingleton pour Dio afin d'avoir une instance unique partagée
  getIt.registerLazySingleton(() => Dio());
  getIt.registerLazySingleton(() => Connectivity());

  //! Core
  // Nous enregistrons nos services core
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(connectivity: getIt()));
  getIt.registerLazySingleton<PreferencesService>(
    () => PreferencesService(getIt<SharedPreferences>()),
  );
  getIt.registerLazySingleton(() => TokenService(getIt()));
  
  // Services d'initialisation
  await HiveService.init();

  //! Features - Auth
  // Data sources
  // Nous séparons clairement les sources de données distantes (API) et locales (Cache)
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: getIt()),
  );
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(),
  );

  // Repository
  // Le repository agit comme une source de vérité unique, orchestrant les data sources
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      networkInfo: getIt(),
      tokenService: getIt(),
    ),
  );

  // Use cases
  // Chaque use case encapsule une règle métier spécifique
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt()));
  getIt.registerLazySingleton(() => GetCurrentUserUseCase(getIt()));
  getIt.registerLazySingleton(() => IsAuthenticatedUseCase(getIt()));

  // Presentation
  // Nous utilisons registerFactory pour les BLoCs car ils doivent être recréés à chaque besoin (et disposés)
  getIt.registerFactory(
    () => AuthBloc(
      loginUseCase: getIt(),
      registerUseCase: getIt(),
      logoutUseCase: getIt(),
      getCurrentUserUseCase: getIt(),
      isAuthenticatedUseCase: getIt(),
    ),
  );

  // Features - Projects
  getIt.registerLazySingleton<ProjectRemoteDataSource>(
    () => ProjectRemoteDataSourceImpl(dio: getIt<Dio>()),
  );
  getIt.registerLazySingleton<ProjectLocalDataSource>(
    () => ProjectLocalDataSourceImpl(),
  );
  getIt.registerLazySingleton<ProjectRepository>(
    () => ProjectRepositoryImpl(
      remoteDataSource: getIt<ProjectRemoteDataSource>(),
      localDataSource: getIt<ProjectLocalDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
    ),
  );
  getIt.registerLazySingleton(() => GetProjectsUseCase(getIt<ProjectRepository>()));
  getIt.registerLazySingleton(() => GetProjectByIdUseCase(getIt<ProjectRepository>()));
  getIt.registerLazySingleton(() => CreateProjectUseCase(getIt<ProjectRepository>()));
  getIt.registerLazySingleton(() => UpdateProjectUseCase(getIt<ProjectRepository>()));
  getIt.registerLazySingleton(() => DeleteProjectUseCase(getIt<ProjectRepository>()));
  getIt.registerLazySingleton(() => GetProjectStatisticsUseCase(getIt<ProjectRepository>()));
  getIt.registerLazySingleton(() => UpdateProjectProgressUseCase(getIt<ProjectRepository>()));
  // UseDependency registered late because of circular dependency resolution capability of GetIt (lazy)
  getIt.registerLazySingleton(() => CalculateProjectProgressUseCase(getIt<TaskRepository>()));

  getIt.registerFactory(
    () => ProjectBloc(
      getProjectsUseCase: getIt<GetProjectsUseCase>(),
      getProjectByIdUseCase: getIt<GetProjectByIdUseCase>(),
      createProjectUseCase: getIt<CreateProjectUseCase>(),
      updateProjectUseCase: getIt<UpdateProjectUseCase>(),
      deleteProjectUseCase: getIt<DeleteProjectUseCase>(),
      getProjectStatisticsUseCase: getIt<GetProjectStatisticsUseCase>(),
      updateProjectProgressUseCase: getIt<UpdateProjectProgressUseCase>(),
    ),
  );

  //! Features - Tasks
  // Data sources
  getIt.registerLazySingleton<TaskRemoteDataSource>(
    () => TaskRemoteDataSourceImpl(dio: getIt()),
  );
  getIt.registerLazySingleton<TaskLocalDataSource>(
    () => TaskLocalDataSourceImpl(),
  );

  // Repository
  getIt.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton(() => CreateTaskUseCase(getIt()));
  getIt.registerLazySingleton(() => GetTasksUseCase(getIt()));
  getIt.registerLazySingleton(() => GetTasksByProjectUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateTaskUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteTaskUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateTaskStatusUseCase(getIt()));
  getIt.registerLazySingleton(() => GetTaskStatisticsUseCase(getIt()));
  getIt.registerLazySingleton(() => SyncTasksWithProjectUseCase(
    taskRepository: getIt(),
    calculateProjectProgressUseCase: getIt(),
    updateProjectProgressUseCase: getIt(),
  ));

  // Bloc - Tasks
  getIt.registerFactory(
    () => TaskBloc(
      getTasksUseCase: getIt<GetTasksUseCase>(),
      getTasksByProjectUseCase: getIt<GetTasksByProjectUseCase>(),
      createTaskUseCase: getIt<CreateTaskUseCase>(),
      updateTaskUseCase: getIt<UpdateTaskUseCase>(),
      updateTaskStatusUseCase: getIt<UpdateTaskStatusUseCase>(),
      deleteTaskUseCase: getIt<DeleteTaskUseCase>(),
      syncTasksWithProjectUseCase: getIt<SyncTasksWithProjectUseCase>(),
    ),
  );

  // Features - Dashboard
  getIt.registerFactory(
    () => DashboardBloc(
      getProjectsUseCase: getIt<GetProjectsUseCase>(),
      getProjectStatisticsUseCase: getIt<GetProjectStatisticsUseCase>(),
      getTasksUseCase: getIt<GetTasksUseCase>(),
      getTaskStatisticsUseCase: getIt<GetTaskStatisticsUseCase>(),
    ),
  );
}
