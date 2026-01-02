class ApiConstants {
  static const String baseUrl = 'https://api.pegasus-app.com';
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String projects = '/api/projects';
  static const String tasks = '/api/tasks';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
