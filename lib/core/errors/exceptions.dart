// Exceptions
class ServerException implements Exception {
  final String message;
  final int statusCode;
  
  ServerException({required this.message, required this.statusCode});
}

class CacheException implements Exception {
  final String message;
  
  CacheException({required this.message});
}

class NetworkException implements Exception {
  final String message;
  
  NetworkException({required this.message});
}
