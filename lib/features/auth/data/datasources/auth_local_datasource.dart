import 'package:hive/hive.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearCachedUser();
  Future<bool> hasCachedUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _userBox = 'user_box';
  static const String _userKey = 'current_user';

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final box = await Hive.openBox<UserModel>(_userBox);
      await box.put(_userKey, user);
      await box.close();
    } catch (e) {
      throw CacheException(message: 'Failed to cache user: $e');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final box = await Hive.openBox<UserModel>(_userBox);
      final user = box.get(_userKey);
      await box.close();
      return user;
    } catch (e) {
      throw CacheException(message: 'Failed to get cached user: $e');
    }
  }

  @override
  Future<void> clearCachedUser() async {
    try {
      final box = await Hive.openBox<UserModel>(_userBox);
      await box.delete(_userKey);
      await box.close();
    } catch (e) {
      throw CacheException(message: 'Failed to clear cached user: $e');
    }
  }

  @override
  Future<bool> hasCachedUser() async {
    try {
      final box = await Hive.openBox<UserModel>(_userBox);
      final hasUser = box.containsKey(_userKey);
      await box.close();
      return hasUser;
    } catch (e) {
      return false;
    }
  }
}
