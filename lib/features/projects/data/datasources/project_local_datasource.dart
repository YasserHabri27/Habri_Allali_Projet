import 'package:hive/hive.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/project_model.dart';

abstract class ProjectLocalDataSource {
  Future<void> cacheProjects(List<ProjectModel> projects);
  Future<List<ProjectModel>> getCachedProjects();
  Future<ProjectModel?> getCachedProjectById(String id);
  Future<void> cacheProject(ProjectModel project);
  Future<void> deleteCachedProject(String id);
  Future<void> clearCachedProjects();
}

class ProjectLocalDataSourceImpl implements ProjectLocalDataSource {
  static const String _projectsBox = 'projects_box';

  @override
  Future<void> cacheProjects(List<ProjectModel> projects) async {
    try {
      final box = await Hive.openBox<ProjectModel>(_projectsBox);
      await box.clear();
      for (final project in projects) {
        await box.put(project.id, project);
      }
      await box.close();
    } catch (e) {
      throw CacheException(message: 'Failed to cache projects: $e');
    }
  }

  @override
  Future<List<ProjectModel>> getCachedProjects() async {
    try {
      final box = await Hive.openBox<ProjectModel>(_projectsBox);
      final projects = box.values.toList();
      await box.close();
      return projects;
    } catch (e) {
      throw CacheException(message: 'Failed to get cached projects: $e');
    }
  }

  @override
  Future<ProjectModel?> getCachedProjectById(String id) async {
    try {
      final box = await Hive.openBox<ProjectModel>(_projectsBox);
      final project = box.get(id);
      await box.close();
      return project;
    } catch (e) {
      throw CacheException(message: 'Failed to get cached project: $e');
    }
  }

  @override
  Future<void> cacheProject(ProjectModel project) async {
    try {
      final box = await Hive.openBox<ProjectModel>(_projectsBox);
      await box.put(project.id, project);
      await box.close();
    } catch (e) {
      throw CacheException(message: 'Failed to cache project: $e');
    }
  }

  @override
  Future<void> deleteCachedProject(String id) async {
    try {
      final box = await Hive.openBox<ProjectModel>(_projectsBox);
      await box.delete(id);
      await box.close();
    } catch (e) {
      throw CacheException(message: 'Failed to delete cached project: $e');
    }
  }

  @override
  Future<void> clearCachedProjects() async {
    try {
      final box = await Hive.openBox<ProjectModel>(_projectsBox);
      await box.clear();
      await box.close();
    } catch (e) {
      throw CacheException(message: 'Failed to clear cached projects: $e');
    }
  }
}
