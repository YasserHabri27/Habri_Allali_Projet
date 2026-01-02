import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/task_model.dart';

abstract class TaskRemoteDataSource {
  Future<TaskModel> createTask(TaskModel task);
  Future<List<TaskModel>> getTasks();
  Future<TaskModel> getTaskById(String id);
  Future<TaskModel> updateTask(TaskModel task);
  Future<void> deleteTask(String id);
  Future<List<TaskModel>> getTasksByProject(String projectId);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final Dio dio;
  TaskRemoteDataSourceImpl({required this.dio});

  @override
  Future<TaskModel> createTask(TaskModel task) async {
    try {
      final response = await dio.post(
        ApiConstants.tasks,
        data: task.toJson(),
      );
      if (response.statusCode == 201) {
        return TaskModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to create task',
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
  Future<List<TaskModel>> getTasks() async {
    try {
      final response = await dio.get(ApiConstants.tasks);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => TaskModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch tasks',
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
  Future<TaskModel> getTaskById(String id) async {
    try {
      final response = await dio.get('${ApiConstants.tasks}/$id');
      if (response.statusCode == 200) {
        return TaskModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Task not found',
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
  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      final response = await dio.put(
        '${ApiConstants.tasks}/${task.id}',
        data: task.toJson(),
      );
      if (response.statusCode == 200) {
        return TaskModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to update task',
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
  Future<void> deleteTask(String id) async {
    try {
      final response = await dio.delete('${ApiConstants.tasks}/$id');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to delete task',
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
  Future<List<TaskModel>> getTasksByProject(String projectId) async {
    try {
      final response = await dio.get(
        '${ApiConstants.tasks}?projectId=$projectId',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => TaskModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to fetch tasks by project',
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
}
