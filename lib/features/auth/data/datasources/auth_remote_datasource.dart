import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String name, String email, String password);
  Future<void> logout(String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Login failed',
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
  Future<UserModel> register(String name, String email, String password) async {
    try {
      final response = await dio.post(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 201) {
        return UserModel.fromJson(response.data);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Registration failed',
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
  Future<void> logout(String token) async {
    try {
      await dio.post(
        '${ApiConstants.baseUrl}/logout',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException {
      // Même en cas d'erreur, on considère le logout comme réussi côté client
    }
  }
}
