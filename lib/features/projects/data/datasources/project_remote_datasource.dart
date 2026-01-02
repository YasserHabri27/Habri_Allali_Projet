import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/project_model.dart';

abstract class ProjectRemoteDataSource {
  Future<ProjectModel> createProject(ProjectModel project);
  Future<List<ProjectModel>> getProjects();
  Future<ProjectModel> getProjectById(String id);
  Future<ProjectModel> updateProject(ProjectModel project);
  Future<void> deleteProject(String id);
  Future<void> updateProjectProgress(String projectId, double progress);
}

class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  final Dio dio;
  ProjectRemoteDataSourceImpl({required this.dio});

  @override
  Future<ProjectModel> createProject(ProjectModel project) async {
    try {
      final response = await dio.post(
        ApiConstants.projects,
        data: project.toJson(),
      );
      if (response.statusCode == 201) {
        return ProjectModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to create project',
          statusCode: response.statusCode!,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  @override
  Future<List<ProjectModel>> getProjects() async {
    try {
      final response = await dio.get(ApiConstants.projects);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ProjectModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch projects',
          statusCode: response.statusCode!,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  @override
  Future<ProjectModel> getProjectById(String id) async {
    try {
      final response = await dio.get('${ApiConstants.projects}/$id');
      if (response.statusCode == 200) {
        return ProjectModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Project not found',
          statusCode: response.statusCode!,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  @override
  Future<ProjectModel> updateProject(ProjectModel project) async {
    try {
      final response = await dio.put(
        '${ApiConstants.projects}/${project.id}',
        data: project.toJson(),
      );
      if (response.statusCode == 200) {
        return ProjectModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to update project',
          statusCode: response.statusCode!,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  @override
  Future<void> deleteProject(String id) async {
    try {
      final response = await dio.delete('${ApiConstants.projects}/$id');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to delete project',
          statusCode: response.statusCode!,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  @override
  Future<void> updateProjectProgress(String projectId, double progress) async {
    try {
      await dio.patch(
        '${ApiConstants.projects}/$projectId/progress',
        data: {'progress': progress},
      );
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }
}
