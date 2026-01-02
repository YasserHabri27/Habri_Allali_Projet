import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/projects/data/models/project_model.dart';
import '../../features/tasks/data/models/task_model.dart';

class HiveService {
  static Future<void> init() async {
    // Initialisation compatible Web et Mobile
    await Hive.initFlutter();
    
    // Enregistrement des adapters pour permettre la sérialisation des objets
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(ProjectModelAdapter());
    Hive.registerAdapter(TaskModelAdapter());
  }
  
  static Future<void> openBoxes() async {
    await Hive.openBox<UserModel>('users');
    await Hive.openBox<ProjectModel>('projects');
    await Hive.openBox<TaskModel>('tasks');
  }
  
  static Future<void> clearAll() async {
    await Hive.deleteFromDisk();
  }
}
