import 'package:hive/hive.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/task_model.dart';

abstract class TaskLocalDataSource {
  Future<void> cacheTasks(List<TaskModel> tasks);
  Future<List<TaskModel>> getCachedTasks();
  Future<TaskModel?> getCachedTaskById(String id);
  Future<void> cacheTask(TaskModel task);
  Future<void> deleteCachedTask(String id);
  Future<void> clearCachedTasks();
  Future<List<TaskModel>> getCachedTasksByProject(String projectId);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  static const String _tasksBox = 'tasks_box';

  @override
  Future<void> cacheTasks(List<TaskModel> tasks) async {
    try {
      final box = await Hive.openBox<TaskModel>(_tasksBox);
      await box.clear();
      for (final task in tasks) {
        await box.put(task.id, task);
      }
      // Nous fermons la boîte après usage pour libérer les ressources, conformément aux bonnes pratiques Hive
      await box.close(); 
    } catch (e) {
      throw CacheException(message: 'Failed to cache tasks: $e');
    }
  }

  @override
  Future<List<TaskModel>> getCachedTasks() async {
    try {
      final box = await Hive.openBox<TaskModel>(_tasksBox);
      final tasks = box.values.toList();
      await box.close();
      return tasks;
    } catch (e) {
      throw CacheException(message: 'Failed to get cached tasks: $e');
    }
  }

  @override
  Future<TaskModel?> getCachedTaskById(String id) async {
    try {
      final box = await Hive.openBox<TaskModel>(_tasksBox);
      final task = box.get(id);
      await box.close();
      return task;
    } catch (e) {
      throw CacheException(message: 'Failed to get cached task: $e');
    }
  }

  @override
  Future<void> cacheTask(TaskModel task) async {
    try {
      final box = await Hive.openBox<TaskModel>(_tasksBox);
      await box.put(task.id, task);
      await box.close();
    } catch (e) {
      throw CacheException(message: 'Failed to cache task: $e');
    }
  }

  @override
  Future<void> deleteCachedTask(String id) async {
    try {
      final box = await Hive.openBox<TaskModel>(_tasksBox);
      await box.delete(id);
      await box.close();
    } catch (e) {
      throw CacheException(message: 'Failed to delete cached task: $e');
    }
  }

  @override
  Future<void> clearCachedTasks() async {
    try {
      final box = await Hive.openBox<TaskModel>(_tasksBox);
      await box.clear();
      await box.close();
    } catch (e) {
      throw CacheException(message: 'Failed to clear cached tasks: $e');
    }
  }

  @override
  Future<List<TaskModel>> getCachedTasksByProject(String projectId) async {
    try {
      final box = await Hive.openBox<TaskModel>(_tasksBox);
      final allTasks = box.values.toList();
      await box.close();
      return allTasks.where((task) => task.projectId == projectId).toList();
    } catch (e) {
      throw CacheException(message: 'Failed to get cached tasks by project: $e');
    }
  }
}
