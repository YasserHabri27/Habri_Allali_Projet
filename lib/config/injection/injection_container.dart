import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/api_client.dart';
import '../../core/network/network_info.dart';
import '../../core/storage/hive_service.dart';
import '../../core/storage/preferences_service.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);
  getIt.registerLazySingleton<Dio>(() => ApiClient.createDio()); // Use ApiClient.createDio() instead of new Dio() directly to get the interceptors
  getIt.registerLazySingleton(() => Connectivity());
  
  // Core
  getIt.registerLazySingleton<PreferencesService>(
    () => PreferencesService(getIt<SharedPreferences>()),
  );
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectivity: getIt<Connectivity>()),
  );
  
  // Services d'initialisation
  await HiveService.init();
  
  // Note: Les repositories et datasources seront ajoutés plus tard
  // lors de l'implémentation des features
}
