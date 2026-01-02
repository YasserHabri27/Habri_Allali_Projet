import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class HiveService {
  static Future<void> init() async {
    // Hive init for Flutter is already handled in main.dart via Hive.initFlutter(),
    // but initializing it with a specific path is good for tests or non-web platforms if needed.
    // However, Hive.initFlutter() usually handles finding the path. 
    // The user code requested exactly this implementation:
    // Initialisation compatible Web et Mobile
    await Hive.initFlutter();
    
    // Register adapters (à compléter plus tard avec les modèles)
    // Hive.registerAdapter(UserModelAdapter());
    // Hive.registerAdapter(ProjectModelAdapter());
    // Hive.registerAdapter(TaskModelAdapter());
  }
  
  static Future<void> openBoxes() async {
    // À compléter plus tard
    // await Hive.openBox<UserModel>('users');
    // await Hive.openBox<ProjectModel>('projects');
    // await Hive.openBox<TaskModel>('tasks');
  }
  
  static Future<void> clearAll() async {
    await Hive.deleteFromDisk();
  }
}
