import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pegasus_app/core/network/api_client.dart';
import 'package:pegasus_app/core/network/network_info.dart';
import 'package:pegasus_app/core/storage/hive_service.dart';
import 'package:pegasus_app/core/storage/preferences_service.dart';
import 'package:pegasus_app/core/storage/data_seeder.dart';

import 'package:pegasus_app/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:pegasus_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pegasus_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:pegasus_app/features/auth/data/services/token_service.dart';
import 'package:pegasus_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:pegasus_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:pegasus_app/features/auth/domain/usecases/is_authenticated_usecase.dart';
import 'package:pegasus_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:pegasus_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:pegasus_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:pegasus_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pegasus_app/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:pegasus_app/features/projects/data/repositories/mock_project_repository.dart';
import 'package:pegasus_app/features/tasks/data/repositories/mock_task_repository.dart';

import 'package:pegasus_app/features/projects/data/datasources/project_local_datasource.dart';
import 'package:pegasus_app/features/projects/data/datasources/project_remote_datasource.dart';
import 'package:pegasus_app/features/projects/data/repositories/project_repository_impl.dart';
import 'package:pegasus_app/features/projects/domain/repositories/project_repository.dart';
import 'package:pegasus_app/features/projects/domain/usecases/calculate_project_progress_usecase.dart';
import 'package:pegasus_app/features/projects/domain/usecases/create_project_usecase.dart';
import 'package:pegasus_app/features/projects/domain/usecases/delete_project_usecase.dart';
import 'package:pegasus_app/features/projects/domain/usecases/get_project_by_id_usecase.dart';
import 'package:pegasus_app/features/projects/domain/usecases/get_project_statistics_usecase.dart';
import 'package:pegasus_app/features/projects/domain/usecases/get_projects_usecase.dart';
import 'package:pegasus_app/features/projects/domain/usecases/update_project_progress_usecase.dart';
import 'package:pegasus_app/features/projects/domain/usecases/update_project_usecase.dart';
import 'package:pegasus_app/features/projects/domain/usecases/recalculate_project_progress_usecase.dart';
import 'package:pegasus_app/features/projects/presentation/bloc/project_bloc.dart';

import 'package:pegasus_app/features/tasks/data/datasources/task_local_datasource.dart';
import 'package:pegasus_app/features/tasks/data/datasources/task_remote_datasource.dart';
import 'package:pegasus_app/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:pegasus_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:pegasus_app/features/tasks/domain/usecases/create_task_usecase.dart';
import 'package:pegasus_app/features/tasks/domain/usecases/delete_task_usecase.dart';
import 'package:pegasus_app/features/tasks/domain/usecases/get_task_statistics_usecase.dart';
import 'package:pegasus_app/features/tasks/domain/usecases/get_tasks_by_project_usecase.dart';
import 'package:pegasus_app/features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'package:pegasus_app/features/tasks/domain/usecases/sync_tasks_with_project_usecase.dart';
import 'package:pegasus_app/features/tasks/domain/usecases/update_task_status_usecase.dart';
import 'package:pegasus_app/features/tasks/domain/usecases/update_task_usecase.dart';
import 'package:pegasus_app/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:pegasus_app/features/dashboard/presentation/bloc/dashboard_bloc.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  //! External
  // Nous enregistrons ici les dépendances externes tierces avec gestion d'erreurs
  try {
    final sharedPreferences = await SharedPreferences.getInstance()
        .timeout(const Duration(seconds: 3));
    getIt.registerLazySingleton(() => sharedPreferences);
  } catch (e) {
    // En cas d'échec, nous créons une instance vide pour éviter le blocage
    print('⚠️ Warning: SharedPreferences initialization failed: $e');
    // On continue sans SharedPreferences - PreferencesService gérera le fallback
  }
  
  // Nous utilisons LazySingleton pour Dio afin de garantir une instance unique partagée pour les appels réseaux
  getIt.registerLazySingleton(() => Dio());
  getIt.registerLazySingleton(() => Connectivity());

  //! Core
  // Enregistrement des services fondamentaux de l'application
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(connectivity: getIt()));
  getIt.registerLazySingleton<PreferencesService>(
    () => PreferencesService(getIt.isRegistered<SharedPreferences>() ? getIt<SharedPreferences>() : null),
  );
  getIt.registerLazySingleton(() => TokenService(getIt()));
  
  // Initialisation des services nécessitant un démarrage asynchrone avec gestion d'erreur
  try {
    await HiveService.init();
    await HiveService.openBoxes();
    print('✅ Hive initialized and boxes opened successfully');
  } catch (e) {
    print('⚠️ Warning: Hive initialization failed: $e. Using in-memory cache.');
    // L'application continuera sans cache persistant local
  }
  
  // Nous peuplons la base de données avec des données de démonstration si c'est le premier lancement
  try {
    await DataSeeder.seedIfNeeded();
  } catch (e) {
    print('⚠️ Warning: Data seeding failed: $e');
  }

  //! Features - Auth
  // Data sources
  // Nous distinguons clairement les sources de données distantes (API) et locales (Cache/Stockage sécurisé)
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: getIt()),
  );
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(),
  );

  // Repository
  // Le repository agit comme source de vérité unique, orchestrant la logique entre les données distantes et locales
  // Repository
  // Nous utilisons maintenant les vrais repositories avec Hive comme stockage local
  const bool useMockData = false; // This flag controls other repositories
  // Auth Repository - USING MOCK FOR OFFLINE SUPPORT
  // Le MockAuthRepository fonctionne sans vérification réseau
  print('🔐 AUTH: Using MockAuthRepository (offline support)');
  getIt.registerLazySingleton<AuthRepository>(
    () => MockAuthRepository(
      localDataSource: getIt(),
    ),
  );

  // Use cases
  // Chaque UseCase encapsule une règle métier atomique et spécifique
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt()));
  getIt.registerLazySingleton(() => GetCurrentUserUseCase(getIt()));
  getIt.registerLazySingleton(() => IsAuthenticatedUseCase(getIt()));

  // Presentation - Auth
  // Nous utilisons registerFactory pour les BLoCs afin qu'une nouvelle instance soit créée à chaque demande, facilitant la gestion de la mémoire
  getIt.registerFactory(
    () => AuthBloc(
      loginUseCase: getIt(),
      registerUseCase: getIt(),
      logoutUseCase: getIt(),
      getCurrentUserUseCase: getIt(),
      isAuthenticatedUseCase: getIt(),
    ),
  );

  //! Features - Projects
  // Configuration des couches Data, Domain et Presentation pour le module Projets
  getIt.registerLazySingleton<ProjectRemoteDataSource>(
    () => ProjectRemoteDataSourceImpl(dio: getIt<Dio>()),
  );
  getIt.registerLazySingleton<ProjectLocalDataSource>(
    () => ProjectLocalDataSourceImpl(),
  );
  
  if (useMockData) {
    getIt.registerLazySingleton<ProjectRepository>(() => MockProjectRepository());
  } else {
    getIt.registerLazySingleton<ProjectRepository>(
      () => ProjectRepositoryImpl(
        remoteDataSource: getIt<ProjectRemoteDataSource>(),
        localDataSource: getIt<ProjectLocalDataSource>(),
        networkInfo: getIt<NetworkInfo>(),
      ),
    );
  }
  getIt.registerLazySingleton(() => GetProjectsUseCase(getIt<ProjectRepository>()));
  getIt.registerLazySingleton(() => GetProjectByIdUseCase(getIt<ProjectRepository>()));
  getIt.registerLazySingleton(() => CreateProjectUseCase(getIt<ProjectRepository>()));
  getIt.registerLazySingleton(() => UpdateProjectUseCase(getIt<ProjectRepository>()));
  getIt.registerLazySingleton(() => DeleteProjectUseCase(getIt<ProjectRepository>()));
  getIt.registerLazySingleton(() => GetProjectStatisticsUseCase(getIt<ProjectRepository>()));
  getIt.registerLazySingleton(() => UpdateProjectProgressUseCase(getIt<ProjectRepository>()));
  getIt.registerLazySingleton(() => RecalculateProjectProgressUseCase(
    taskRepository: getIt<TaskRepository>(),
    projectRepository: getIt<ProjectRepository>(),
  ));
  // Ce UseCase est enregistré tardivement pour permettre la résolution des dépendances circulaires via GetIt
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
  // Configuration complète du module Tâches
  // Data sources
  getIt.registerLazySingleton<TaskRemoteDataSource>(
    () => TaskRemoteDataSourceImpl(dio: getIt()),
  );
  getIt.registerLazySingleton<TaskLocalDataSource>(
    () => TaskLocalDataSourceImpl(),
  );

  // Repository
  if (useMockData) {
    getIt.registerLazySingleton<TaskRepository>(() => MockTaskRepository());
  } else {
    getIt.registerLazySingleton<TaskRepository>(
      () => TaskRepositoryImpl(
        remoteDataSource: getIt(),
        localDataSource: getIt(),
        networkInfo: getIt(),
      ),
    );
  }

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
      recalculateProjectProgressUseCase: getIt<RecalculateProjectProgressUseCase>(),
    ),
  );

  // Features - Dashboard
  // Enregistrement du BLoC pour le tableau de bord
  getIt.registerFactory(
    () => DashboardBloc(
      getProjectsUseCase: getIt<GetProjectsUseCase>(),
      getProjectStatisticsUseCase: getIt<GetProjectStatisticsUseCase>(),
      getTasksUseCase: getIt<GetTasksUseCase>(),
      getTaskStatisticsUseCase: getIt<GetTaskStatisticsUseCase>(),
    ),
  );
}
